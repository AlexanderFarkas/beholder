part of '../core.dart';

enum ScopePhase {
  markNeedsUpdate,
  notify,
}

class ObservableScope {
  factory ObservableScope() {
    _current ??= ObservableScope._();
    return _current!;
  }

  static void reset() {
    _current = ObservableScope._();
  }

  void invalidateState(ObservableState observable) {
    bool shouldSchedule = false;
    void visitObserver(ObserverMixin observer) {
      _invalidatedObservers.add(observer);

      if (observer is ObservableObserver) {
        _observableStates.add(observer.inner);
        for (final observer in observer.observers) {
          visitObserver(observer);
        }
      } else {
        shouldSchedule = true;
        _consumerObservers.add(observer);
      }
    }

    for (final observer in observable.observers) {
      visitObserver(observer);
    }

    if (shouldSchedule) {
      _scheduleUpdateConsumers();
    }
  }

  final _invalidatedObservers = <ObserverMixin>{};
  var _observableStates = <ObservableState>{};

  static ObservableScope? _current;
  ObservableScope._();

  Set<ObserverMixin> _consumerObservers = {};

  @visibleForTesting
  static waitForUpdate() async {
    await Future(() {});
  }

  bool _isScheduled = false;
  void _scheduleUpdateConsumers() {
    if (_isScheduled) return;
    _isScheduled = true;

    Future(_updateObservers);
  }

  void _updateObservers() {
    final observers = _consumerObservers;
    final observableStates = _observableStates;
    final updateObserverCache = _updateObserverCache;
    _consumerObservers = {};
    _observableStates = {};
    _updateObserverCache = {};

    _isScheduled = false;

    for (final observer in observers) {
      _updateObserver(
        observer,
        observableStates: observableStates,
        updateObserverCache: updateObserverCache,
      );
      _invalidatedObservers.remove(observer);
    }
  }

  void updateObserver(ObserverMixin observer) {
    final clearCacheFor = <ObserverMixin>{};
    _updateObserver(
      observer,
      onVisited: (o) => clearCacheFor.add(o),
      observableStates: _observableStates,
      updateObserverCache: _updateObserverCache,
    );
    for (final clear in clearCacheFor) {
      _updateObserverCache.remove(clear);
    }
  }

  var _updateObserverCache = <ObserverMixin, bool?>{};
  bool? _updateObserver(
    ObserverMixin observer, {
    void Function(ObserverMixin observer)? onVisited,
    required Set<ObservableState> observableStates,
    required Map<ObserverMixin, bool?> updateObserverCache,
  }) {
    if (updateObserverCache.containsKey(observer)) {
      return updateObserverCache[observer];
    } else if (!_invalidatedObservers.contains(observer)) {
      return null;
    }

    bool? isAnyUpdated;
    for (final observable in observer.observables) {
      if (!observableStates.contains(observable)) {
        continue;
      }

      final observer = observable.delegatedByObserver;
      if (observer != null) {
        final isRebuilt = _updateObserver(
          observer,
          onVisited: onVisited,
          observableStates: observableStates,
          updateObserverCache: updateObserverCache,
        );
        if (isRebuilt == true) {
          isAnyUpdated = true;
        } else {
          isAnyUpdated ??= isRebuilt;
        }
      } else {
        isAnyUpdated = true;
      }
    }

    final bool isRebuilt;
    if (isAnyUpdated != false) {
      final (isRebuiltFn, isNewObservableAdded) = observer.rebuild();
      if (isNewObservableAdded) {
        return _updateObserver(
          observer,
          onVisited: onVisited,
          observableStates: observableStates,
          updateObserverCache: updateObserverCache,
        );
      }
      isRebuilt = isRebuiltFn();
    } else {
      isRebuilt = false;
    }
    _invalidatedObservers.remove(observer);
    updateObserverCache[observer] = isRebuilt;
    onVisited?.call(observer);
    assert(() {
      debugLog("$observer notified. Rebuilt: $isRebuilt");
      return true;
    }());
    return isRebuilt;
  }
}
