part of '../core.dart';

class ObservableComputed<T> extends ObservableObserver<T> {
  ObservableComputed(this._compute, {Equals<T>? equals})
      : _equals = equals ?? Observable.defaultEquals {
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
  final T Function(Watch watch) _compute;

  late T _value;
}

class ObservableWritableComputed<T> extends ObservableComputed<T> implements WritableObservable<T> {
  ObservableWritableComputed(
      {required T Function(Watch watch) get, required void Function(T value) set, super.equals})
      : _set = set,
        super(get);

  @override
  set value(T value) => scopedUpdate(() => _set(value));

  final void Function(T value) _set;
}
