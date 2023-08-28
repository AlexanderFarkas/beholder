part of '../computed.dart';

class ObservableComputed<T> extends ObservableObserver<T> {
  ObservableComputed(this._compute, {Equals<T>? equals});

  @override
  ObservableState<T> createStateDelegate() {
    return ObservableState(observe(_compute));
  }

  @override
  bool Function() performRebuild() {
    final value = observe(_compute);
    return () => stateDelegate.setValue(value);
  }

  final T Function(Watch watch) _compute;
}
