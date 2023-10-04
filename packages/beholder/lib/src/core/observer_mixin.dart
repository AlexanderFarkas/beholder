part of core;

typedef Watch = T Function<T>(Observable<T> observable);

mixin ObserverMixin {
  final observables = <ObservableState>{};
  bool _isNewObservableAddedDuringRebuild = false;

  @protected
  bool Function() performRebuild();

  @internal
  (bool Function() isRebuilt, bool isNewObservableAdded) rebuild() {
    _isNewObservableAddedDuringRebuild = false;
    final isRebuiltFn = performRebuild();
    final result = (isRebuiltFn, _isNewObservableAddedDuringRebuild);
    _isNewObservableAddedDuringRebuild = false;
    return result;
  }

  T _observe<T>(Observable<T> observable) {
    observable.addObserver(this);
    return observable.value;
  }

  T observe<T>(T Function(Watch watch) callback) {
    return callback(_observe);
  }

  void onAddedToState(ObservableState observable) {
    final isNew = observables.add(observable);
    if (isNew) {
      _isNewObservableAddedDuringRebuild = true;
    }
  }

  void stopObserving() {
    for (final observable in {...observables}) {
      observable.removeObserver(this);
    }
  }
}

class ListenObserver with ObserverMixin, DebugReprMixin {
  ListenObserver(this.listener);
  final void Function() listener;

  @override
  bool Function() performRebuild() {
    return () {
      listener();
      return true;
    };
  }
}
