part of core;

typedef Watch = T Function<T>(Watchable<T> observable);
typedef IsApplied = bool;
typedef Rebuild = IsApplied Function();

mixin ObserverMixin {
  final observables = <BaseObservableState>{};

  T trackObservables<T>(T Function(Watch watch) callback) {
    return callback(_observe);
  }

  void onAddedToState(BaseObservableState observable) {
    final isNew = observables.add(observable);
    if (isNew) {
      _isNewObservableAddedDuringPrepare = true;
    }
  }

  void onRemovedFromState(BaseObservableState observable) {
    observables.remove(observable);
  }

  void stopObserving() {
    for (final observable in {...observables}) {
      observable.removeObserver(this);
    }
  }

  @protected
  Rebuild prepare();

  bool _isNewObservableAddedDuringPrepare = false;

  (Rebuild rebuild, bool isNewObservableAdded) prepareAndCountNewObservables() {
    _isNewObservableAddedDuringPrepare = false;

    final (Rebuild rebuild, bool isNewObservableAdded) result;
    try {
      final rebuild = prepare();
      result = (rebuild, _isNewObservableAddedDuringPrepare);
    } finally {
      _isNewObservableAddedDuringPrepare = false;
    }
    return result;
  }

  T _observe<T>(Watchable<T> watchable) {
    switch (watchable) {
      case final _InlineWatchable<T> inline:
        return inline.trackObservables(_observe);
      case final Observable<T> observable:
        observable.addObserver(this);
        return observable.value;
    }
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

  late final BaseObservableState<T> _observableState;
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
  void onAddedToState(BaseObservableState observable) {
    _observableState = observable as BaseObservableState<T>;
    _previousValue = observable.value;
    super.onAddedToState(observable);
  }
}
