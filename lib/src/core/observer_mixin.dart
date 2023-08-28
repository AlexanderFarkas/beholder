part of '../core.dart';

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

  T observe<T>(Observable<T> observable) {
    observable.addObserver(this);
    return observable.value;
  }

  void onAddedToState(ObservableState observable) {
    if (observables.add(observable)) {
      print("Added during rebuild");
      _isNewObservableAddedDuringRebuild = true;
    }
  }

  void stopObserving() {
    for (final observable in observables) {
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
