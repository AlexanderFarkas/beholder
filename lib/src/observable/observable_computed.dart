part of '../core.dart';

class ObservableComputed<T> extends ObservableObserver<T> {
  ObservableComputed(this._compute, {Equals<T>? equals})
      : _equals = equals ?? Observable._defaultEquals {
    _value = _compute(observe);
  }

  @override
  T get value {
    return _value;
  }

  @override
  @protected
  bool performUpdate() {
    final oldValue = _value;
    _value = _compute(observe);
    return !_equals(oldValue, _value);
  }

  final Equals<T> _equals;
  final T Function(Observe watch) _compute;

  late T _value;
}
