part of core;

class ObservableContext {
  factory ObservableContext() {
    _current ??= ObservableContext._();
    return _current!;
  }

  @visibleForTesting
  static void reset() {
    _current = ObservableContext._();
  }

  void invalidateState(RootObservableState state) {
    bool shouldSchedule = false;
    void visitObserver(ObserverMixin observer) {
      _invalidatedObservers.add(observer);

      if (observer is ObservableObserver) {
        _states.add(observer.inner);
        for (final observer in observer.observers) {
          visitObserver(observer);
        }
      } else {
        shouldSchedule = true;
        _consumerObservers.add(observer);
      }
    }

    for (final observer in state.observers) {
      visitObserver(observer);
    }

    if (shouldSchedule) {
      _scheduleUpdateConsumers();
    }
  }

  void updateObserver(ObserverMixin observer) {
    final clearCacheFor = <ObserverMixin>{};
    _updateObserver(
      observer,
      onVisited: (o) => clearCacheFor.add(o),
      states: _states,
      updateObserverCache: _updateObserverCache,
    );
    for (final clear in clearCacheFor) {
      _updateObserverCache.remove(clear);
    }
  }

  final _invalidatedObservers = <ObserverMixin>{};
  var _states = <RootObservableState>{};

  static ObservableContext? _current;

  ObservableContext._();

  Set<ObserverMixin> _consumerObservers = {};

  @visibleForTesting
  static pump() async {
    await Future.microtask(() {});
  }

  bool _isScheduled = false;

  void _scheduleUpdateConsumers() {
    if (_isScheduled) return;
    _isScheduled = true;

    Future.microtask(_updateObservers);
  }

  void _updateObservers() {
    final observers = _consumerObservers;
    final states = _states;
    final updateObserverCache = _updateObserverCache;
    _consumerObservers = {};
    _states = {};
    _updateObserverCache = {};

    _isScheduled = false;

    for (final observer in observers) {
      _updateObserver(
        observer,
        states: states,
        updateObserverCache: updateObserverCache,
      );
      _invalidatedObservers.remove(observer);
    }
  }

  var _updateObserverCache = <ObserverMixin, bool?>{};

  bool? _updateObserver(
    ObserverMixin observer, {
    void Function(ObserverMixin observer)? onVisited,
    required Set<RootObservableState> states,
    required Map<ObserverMixin, bool?> updateObserverCache,
  }) {
    if (updateObserverCache.containsKey(observer)) {
      return updateObserverCache[observer];
    } else if (!_invalidatedObservers.contains(observer)) {
      return null;
    }

    bool? isAnyUpdated;
    for (final observable in observer.observables) {
      if (!states.contains(observable)) {
        continue;
      }

      final observer = observable.delegatedByObserver;
      if (observer != null) {
        final isRebuilt = _updateObserver(
          observer,
          onVisited: onVisited,
          states: states,
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

    late final bool isRebuilt;
    if (isAnyUpdated != false) {
      try {
        final (applyRebuild, isNewObservableAdded) = observer._prepare();
        if (isNewObservableAdded) {
          return _updateObserver(
            observer,
            onVisited: onVisited,
            states: states,
            updateObserverCache: updateObserverCache,
          );
        }

        isRebuilt = applyRebuild();
      } catch (e) {
        developer.log(
          "$observer failed to rebuild and kept its previous state.\nIf it's expected, ignore this error.\nError: $e",
        );
        isRebuilt = false;
      }
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
