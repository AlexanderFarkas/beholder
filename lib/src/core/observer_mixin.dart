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

  T _observe<T>(Observable<T> observable) {
    observable.addObserver(this);
    return observable.value;
  }

  T observe<T>(T Function(Watch watch) callback) {
    final watcher = ScopedObserver(_observe);
    final result = callback(watcher);
    Future.microtask(watcher.dispose);
    return result;
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

class ScopedObserver {
  final T Function<T>(Observable<T> observable) watch;

  ScopedObserver(this.watch);

  T call<T>(Observable<T> observable) {
    if (isDisposed) {
      throw Exception(
        "Watcher is disposed. Don't store `watch` function and don't use it through async gaps. Try calling `watch` earlier.",
      );
    }
    return watch(observable);
  }

  bool isDisposed = false;

  dispose() {
    isDisposed = true;
  }
}
