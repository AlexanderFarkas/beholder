part of '../computed.dart';

class ObservableComputed<T> extends ObservableObserver<T> {
  ObservableComputed(this._compute, {Equals<T>? equals});

  @override
  ObservableState<T> createStateDelegate() {
    return ObservableState(_compute(observe));
  }

  @override
  bool rebuild() {
    final value = _compute(observe);
    debugLog("Rebuilt $this with $value");
    return stateDelegate.setValue(value);
  }

  final T Function(Watch watch) _compute;
}
