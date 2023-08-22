part of '../core.dart';

class ObservableState<T> extends Observable<T> {
  ObservableState(T value, {Equals<T>? equals})
      : _value = value,
        _equals = equals ?? Observable._defaultEquals;

  @override
  T get value => _value;
  set value(T value) {
    final oldValue = _value;
    _value = value;
    if (_equals(oldValue, value)) return;
    ObservableScope.markNeedsUpdate(this);
  }

  T update(T Function(T previous) updater) {
    value = updater(value);
    return value;
  }

  final Equals<T> _equals;

  T _value;
}
