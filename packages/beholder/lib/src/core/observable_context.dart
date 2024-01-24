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

  @visibleForTesting
  static Future<void> pump() async {
    await Future.microtask(() {});
  }

  static ObservableContext? _current;

  ObservableContext._();

  void invalidateState(RootObservableState state) {
    _uow.invalidateState(state);
    _scheduleUpdateObservers();
  }

  void trackComputedCreated(ObservableComputed computed) {
    _uow.trackComputedCreated(computed);
  }

  void updateComputed(ObservableComputed computed) {
    _uow.updateObservable(
      computed.inner,
      isNew: (RootObservableState state) => true,
      isDirect: true,
    );
  }

  bool isScheduled = false;

  void _scheduleUpdateObservers() {
    if (isScheduled) return;
    Future.microtask(() {
      final old = _uow;
      isScheduled = false;
      _uow = _UpdateUnitOfWork(old.computedRebuildCache);
      old._execute();
    });
  }

  var _uow = _UpdateUnitOfWork(null);
}

class _UpdateUnitOfWork {
  _UpdateUnitOfWork(this.previousRebuildCache);

  Map<ObservableComputed, bool>? previousRebuildCache;
  final Map<ObservableComputed, bool> computedRebuildCache = {};
  final invalidatedRoots = <RootObservableState>{};
  final directlyRebuiltComputedsValuesBeforeRebuild = <ObservableComputed, dynamic>{};

  void invalidateState(RootObservableState state) {
    invalidatedRoots.add(state);
    previousRebuildCache = null;
    computedRebuildCache.clear();
  }

  void trackComputedCreated(ObservableComputed computed) {
    computedRebuildCache[computed] = true;
  }

  void _execute() {
    final computedNeedUpdate = <ObservableComputed>{};
    final leafObservers = <ObserverMixin>{};
    void visitObserver(ObserverMixin observer) {
      if (observer case final ObservableComputed computed) {
        computedNeedUpdate.add(computed);
        for (final observer in computed.observers) {
          visitObserver(observer);
        }
      } else {
        leafObservers.add(observer);
      }
    }

    for (final root in invalidatedRoots) {
      for (final observer in root.observers) {
        visitObserver(observer);
      }
    }

    for (final leaf in leafObservers) {
      bool isAnyRebuilt = false;
      for (final observable in leaf.observables) {
        if (updateObservable(
          observable,
          isNew: (state) => invalidatedRoots.contains(state),
        )) {
          isAnyRebuilt = true;
        }
      }

      if (isAnyRebuilt) {
        try {
          while (true) {
            final (rebuild, isNewObservableAdded) = leaf.prepareAndCountNewObservables();
            if (!isNewObservableAdded) {
              rebuild();
              break;
            }
          }
        } catch (e, s) {
          _debugLogErrorDuringRebuild(e, s, observer: leaf);
        }
      }
    }
  }

  bool updateObservable(
    BaseObservableState state, {
    required bool Function(RootObservableState state) isNew,
    isDirect = false,
  }) {
    switch (state) {
      case final ComputedState computed:
        bool isAnyRebuilt = false;
        final observer = computed.delegatedBy;

        if (computedRebuildCache[observer] case final cached?) {
          return cached;
        } else if (previousRebuildCache?[observer] case final cached?) {
          return cached;
        }

        for (final observable in observer.observables) {
          if (updateObservable(observable, isNew: isNew)) {
            isAnyRebuilt = true;
          }
        }

        if (isAnyRebuilt) {
          final valueBeforeRebuild = computed.value;
          while (true) {
            final (rebuild, isNewObservableAdded) = observer.prepareAndCountNewObservables();
            if (isNewObservableAdded) {
              continue;
            }

            final isRebuilt = rebuild();

            final valueBeforeRebuilds = directlyRebuiltComputedsValuesBeforeRebuild[observer];
            final result = computedRebuildCache[observer] = valueBeforeRebuilds != null
                ? isRebuilt || computed.equals(valueBeforeRebuild, computed.value)
                : isRebuilt;

            if (isDirect) {
              directlyRebuiltComputedsValuesBeforeRebuild[observer] = valueBeforeRebuild;
            }
            return result;
          }
        } else {
          return computedRebuildCache[observer] = false;
        }
      case final RootObservableState state:
        return isNew(state);
    }
  }
}

void _debugLogErrorDuringRebuild(
  Object error,
  StackTrace stackTrace, {
  required ObserverMixin observer,
}) {
  debugLog(
    "$observer failed to rebuild and kept its previous state.\nIf it's expected, ignore this error.\nError: $error\n$stackTrace",
  );
}
