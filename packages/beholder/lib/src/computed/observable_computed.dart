part of computed;

class ObservableComputed<T> extends ObservableObserver<T> {
  ObservableComputed(this._compute, {Equals<T>? equals});

  @override
  ObservableState<T> createStateDelegate() =>
      ObservableState(trackObservables(_compute));

  @override
  Rebuild prepare() {
    print(_compute.hashCode);
    final value = trackObservables(_compute);
    return () => inner.setValue(value);
  }

  final T Function(Watch watch) _compute;
}
