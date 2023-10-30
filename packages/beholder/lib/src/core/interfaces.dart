part of core;

abstract interface class Disposable {
  void dispose();
}

abstract interface class Observable<T> implements Disposable {
  static bool debugEnabled = false;
  static bool Function(Object? previous, Object? current) defaultEquals =
      (previous, current) => previous == current;

  T get value;

  /// Stream of [Observable]'s values.
  /// Emits whenever value is set
  Stream<T> asStream();

  Disposer listen(ValueChanged<T> onChanged);
  void addObserver(ObserverMixin observer);
  void removeObserver(ObserverMixin observer);
  UnmodifiableSetView<ObserverMixin> get observers;
}

abstract interface class WritableObservable<T> implements Observable<T> {
  set value(T value);
}

extension WritableObservableX<T> on WritableObservable<T> {
  void update(T Function(T current) updater) => value = updater(value);
}

abstract interface class ObservableState<T> implements WritableObservable<T>, Extendable<T> {
  factory ObservableState(
    T value, {
    Equals<T>? equals,
  }) = RootObservableState;

  /// [bool] indicates if value was actually set,
  /// i.e. not discarded by `equals`
  bool setValue(T value);

  /// [onChanged] is called before *any* other observer is notified.
  /// This is useful if you want to update other [RootObservableState]s in the same [ObservableContext] phase.
  ///
  /// Use it only if you know what you are doing.
  /// Safer, but less performant, alternative is to use [listen].
  Disposer listenSync(ValueChanged<T> onChanged);
}
