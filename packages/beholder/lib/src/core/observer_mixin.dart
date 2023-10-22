part of core;

typedef Watch = T Function<T>(Observable<T> observable);
typedef IsApplied = bool;
typedef Rebuild = IsApplied Function();

mixin ObserverMixin {
  final observables = <RootObservableState>{};

  T trackObservables<T>(T Function(Watch watch) callback) {
    return callback(_observe);
  }

  void onAddedToState(RootObservableState observable) {
    final isNew = observables.add(observable);
    if (isNew) {
      _isNewObservableAddedDuringRebuild = true;
    }
  }

  void onRemovedFromState(RootObservableState observable) {
    observables.remove(observable);
  }

  void stopObserving() {
    for (final observable in {...observables}) {
      observable.removeObserver(this);
    }
  }

  @protected
  Rebuild prepare();

  bool _isNewObservableAddedDuringRebuild = false;

  (Rebuild rebuild, bool isNewObservableAdded) _prepare() {
    _isNewObservableAddedDuringRebuild = false;
    final rebuild = prepare();
    final result = (rebuild, _isNewObservableAddedDuringRebuild);
    _isNewObservableAddedDuringRebuild = false;
    return result;
  }

  T _observe<T>(Observable<T> observable) {
    observable.addObserver(this);
    return observable.value;
  }
}

class ListenObserver with ObserverMixin, DebugReprMixin {
  ListenObserver(this.listener);
  final void Function() listener;

  @override
  Rebuild prepare() {
    return () {
      listener();
      return true;
    };
  }
}

class ValueChangedObserver<T> with ObserverMixin, DebugReprMixin {
  ValueChangedObserver(this.listener);
  final void Function(T previous, T next) listener;

  late final RootObservableState<T> _observableState;
  late T _previousValue;

  @override
  Rebuild prepare() {
    return () {
      listener(_previousValue, _observableState.value);
      _previousValue = _observableState.value;
      return true;
    };
  }

  @override
  void onAddedToState(RootObservableState observable) {
    _observableState = observable as RootObservableState<T>;
    _previousValue = observable.value;
    super.onAddedToState(observable);
  }
}
