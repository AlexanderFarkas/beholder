part of computed;

class ObservableComputed<T> extends ObservableObserver<T> {
  ObservableComputed(this._compute, {Equals<T>? equals});

  @override
  RootObservableState<T> createStateDelegate() =>
      RootObservableState(trackObservables(_compute));

  @override
  Rebuild prepare() {
    final value = trackObservables(_compute);
    return () => inner.setValue(value);
  }

  final T Function(Watch watch) _compute;
}
