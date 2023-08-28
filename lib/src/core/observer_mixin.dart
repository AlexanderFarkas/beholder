part of '../core.dart';

typedef Watch = T Function<T>(Observable<T> observable);

mixin ObserverMixin {
  final observables = <ObservableState>{};

  @protected
  bool rebuild();

  T observe<T>(Observable<T> observable) {
    observable.addObserver(this);
    return observable.value;
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
  bool rebuild() {
    listener();
    return true;
  }
}
