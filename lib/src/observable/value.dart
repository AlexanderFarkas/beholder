part of '../core.dart';

class ObservableValue<T> extends Observable<T> {
  ObservableValue(T value, {Equals<T>? equals})
      : _value = value,
        equals = equals ?? Observable._defaultEquals;

  final Equals<T> equals;
  T _value;

  @override
  T get value => _value;
  set value(T value) {
    final oldValue = _value;
    _value = value;
    if (equals(oldValue, value)) return;
    ObservableScope.markNeedsUpdate(this);
  }

  T update(T Function(T previous) updater) {
    value = updater(value);
    return value;
  }
}
