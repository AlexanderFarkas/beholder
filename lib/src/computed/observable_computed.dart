part of '../computed.dart';
class ObservableComputed<T> extends DelegatedObservableObserver<T> {
  ObservableComputed(this._compute, {Equals<T>? equals});

  @override
  ObservableState<T> createStateDelegate() {
    return ObservableState(_compute(observe));
  }

  @override
  bool performUpdate() {
    return stateDelegate.setValue(_compute(observe));
  }

  final T Function(Watch watch) _compute;
}
