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

  void invalidate(ObservableState observable) {
    if (!_observableStates.add(observable)) return;

    void inner(ObserverMixin observer) {
      if (!_invalidatedObservers.add(observer)) return;

      if (observer is ObservableObserver) {
        _observableStates.add(observer.stateDelegate);
        for (final observer in observer.observers) {
          inner(observer);
        }
      } else {
        _consumerObservers.add(observer);
      }
    }

    for (final observer in observable.observers) {
      inner(observer);
    }

    _scheduleUpdateConsumers();
  }

  final _invalidatedObservers = <ObserverMixin>{};
  final _observableStates = <ObservableState>{};

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
    _consumerObservers = {};
    for (final observer in observers) {
      _updateObserver(observer);
      _invalidatedObservers.remove(observer);
    }
    _observableStates.clear();
    _updateObserverCache.clear();
    _isScheduled = false;
  }

  void updateObserver(ObserverMixin observer) {
    final clearCacheFor = <ObserverMixin>{};
    _updateObserver(observer, (o) => clearCacheFor.add(o));
    for (final clear in clearCacheFor) {
      _updateObserverCache.remove(clear);
    }
  }

  final _updateObserverCache = <ObserverMixin, bool?>{};
  bool? _updateObserver(ObserverMixin observer,
      [void Function(ObserverMixin observer)? onVisited]) {
    if (_updateObserverCache.containsKey(observer)) {
      return _updateObserverCache[observer];
    } else if (!_invalidatedObservers.contains(observer)) {
      return null;
    }

    bool? isAnyUpdated;
    for (final observable in observer.observables) {
      if (!_observableStates.contains(observable)) {
        continue;
      }

      final observer = observable.delegatedByObserver;
      if (observer != null) {
        final isRebuilt = _updateObserver(observer, onVisited);
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
        return _updateObserver(observer);
      }
      isRebuilt = isRebuiltFn();
    } else {
      isRebuilt = false;
    }
    _invalidatedObservers.remove(observer);
    _updateObserverCache[observer] = isRebuilt;
    onVisited?.call(observer);
    assert(() {
      debugLog("$observer notified. Rebuilt: $isRebuilt");
      return true;
    }());
    return isRebuilt;
  }
}
