part of computed;

class ObservableComputed<T> extends ObservableObserver<T> {
  ObservableComputed(this._compute, {Equals<T>? equals});

  @override
  ObservableState<T> createStateDelegate() => ObservableState(observe(_compute));

  @override
  bool Function() performRebuild() {
    final value = observe(_compute);
    return () => inner.setValue(value);
  }

  final T Function(Watch watch) _compute;
}
