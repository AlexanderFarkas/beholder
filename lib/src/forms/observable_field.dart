part of form;

typedef ComputeError<T> = String? Function(Watch watch, FieldState<T> state);

class ObservableField<T> extends ViewModel with WritableObservableMixin<T> {
  ObservableField(
    T value, {
    required ComputeError<T> computeError,
  }) : _computeError = computeError {
    _fieldState = FieldState(value);
    _fieldState.value.listen(
      (value) => this._innerError.value = null,
      eager: true,
    );
    disposers.add(_fieldState.dispose);
  }

  late final error = writableComputed(
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

  late final FieldState<T> _fieldState;
  late final _innerError = state<String?>(null);
  late final ComputeError<T> _computeError;

  @override
  void addObserver(ObserverMixin observer) => _fieldState.value.addObserver(observer);

  @override
  Stream<T> asStream() => _fieldState.value.asStream();

  @override
  Dispose listen(void Function(T value) onChanged) => _fieldState.value.listen(onChanged);

  @override
  UnmodifiableSetView<ObserverMixin> get observers => _fieldState.value.observers;

  @override
  void removeObserver(ObserverMixin observer) => _fieldState.value.removeObserver(observer);

  @override
  T get value => _fieldState.value.value;

  @override
  bool setValue(T value) => _fieldState.value.setValue(value);
}

class FieldState<T> extends ViewModel {
  FieldState(T initialValue) {
    value = state(initialValue);
    value.listen(
      (value) {
        _wasSet.value = true;
        if (hasFocus.value) {
          _wasSetAfterFocus.value = true;
        }
      },
      eager: true,
    );
    hasFocus.listen(
      (isFocused) {
        _wasSetAfterFocus.value = false;
        if (!isFocused) {
          _wasEverUnfocused.value = true;
        }
      },
      eager: true,
    );
  }

  late final ObservableState<T> value;
  late final hasFocus = state(false);

  late final _wasEverUnfocused = state(false);
  Observable<bool> get wasEverUnfocused => _wasEverUnfocused;
  late final _wasSetAfterFocus = state(false);
  Observable<bool> get wasSetAfterFocus => _wasSetAfterFocus;
  late final _wasSet = state(false);
  Observable<bool> get wasSet => _wasSet;
}
