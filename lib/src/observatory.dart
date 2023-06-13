part of 'core.dart';

class Observatory {
  final Observer observer;
  final observables = <Observable>{};

  Observatory(this.observer);

  T observe<T>(Observable<T> observable) {
    observables.add(observable);
    return observable.value;
  }

  proxy<TResult>(TResult Function(Observe) perform) {
    final oldObservables = {...observables};

    observables.clear();
    final result = perform(observe);
    for (final observable in observables) {
      oldObservables.remove(observable);
      observable.addObserver(observer);
    }

    for (final observable in oldObservables) {
      observable.removeObserver(observer);
    }

    return result;
  }

  void dispose() {
    for (final observable in observables) {
      observable.removeObserver(observer);
    }
  }
}
