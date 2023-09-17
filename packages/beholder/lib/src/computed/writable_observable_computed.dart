part of computed;

class WritableObservableComputed<T> extends ObservableComputed<T> implements WritableObservable<T> {
  WritableObservableComputed(
      {required T Function(Watch watch) get, required void Function(T value) set, super.equals})
      : _set = set,
        super(get);

  @override
  set value(T value) => _set(value);
  void update(T Function(T current) updater) {
    value = updater(value);
  }

  final void Function(T value) _set;
}
