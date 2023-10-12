part of form;

typedef ComputeError<T> = String? Function(Watch watch, FieldState<T> state);

abstract interface class ObservableField<T> implements Observable<T> {
  Observable<String?> get error;
}

class WritableObservableField<T> extends ViewModel
    with ProxyObservableStateMixin<T>, WritableObservableMixin<T>
    implements ObservableField<T> {
  WritableObservableField(
    T value, {
    required ComputeError<T> computeError,
  }) : _computeError = computeError {
    _fieldState = WritableFieldState(value);
    _fieldState.value.listenSync((_, value) => this._innerError.value = null);
    disposers.add(_fieldState.dispose);
  }

  @override
  ObservableState<T> get inner => _fieldState.value;

  @override
  bool setValue(T value) => inner.setValue(value);

  @override
  late final WritableObservableComputed<String?> error = writableComputed(
    get: (watch) {
      final innerError = watch(_innerError);
      if (innerError != null) {
        return innerError;
      }

      return this._computeError(
        watch,
        _fieldState,
      );
    },
    set: (value) => _innerError.value = value,
  );

  late final WritableFieldState<T> _fieldState;
  late final _innerError = state<String?>(null);
  late final ComputeError<T> _computeError;
}
