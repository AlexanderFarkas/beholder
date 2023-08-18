part of 'core.dart';

class Observatory {
  final Observer observer;
  final observables = <Observable>{};

  Observatory(this.observer);

  T observe<T>(Observable<T> observable) {
    observables.add(observable);
    observable.addObserver(observer);
    return observable.value;
  }

  void dispose() {
    for (final observable in observables) {
      observable.removeObserver(observer);
    }
  }
}
