part of '../core.dart';

class ObservableComputed<T> extends Observable<T> with Observer {
  final T Function(Observe watch) compute;
  ObservableComputed(this.compute, {Equals<T>? equals})
      : equals = equals ?? Observable._defaultEquals {
    _value = compute(observe);
  }

  final Equals<T> equals;
  late T _value;

  @override
  T get value {
    return _value;
  }

  @override
  bool performUpdate() {
    final oldValue = _value;
    _value = compute(observe);
    return !equals(oldValue, _value);
  }
}

class Wrapper<T> {
  final T value;

  Wrapper(this.value);
}
