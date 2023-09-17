part of form;

abstract interface class FieldState<T> {
  Observable<T> get value;
  Observable<bool> get hasFocus;
  Observable<bool> get wasEverUnfocused;
  Observable<bool> get wasSetAfterFocus;
  Observable<bool> get wasSet;
}

class WritableFieldState<T> extends ViewModel implements FieldState<T> {
  WritableFieldState(T initialValue) {
    value = state(initialValue, onSet: (value) {
      wasSet.value = true;
      if (hasFocus.value) {
        wasSetAfterFocus.value = true;
      }
    });

    hasFocus.listen(
      (isFocused) {
        wasSetAfterFocus.value = false;
        if (!isFocused) {
          wasEverUnfocused.value = true;
        }
      },
      eager: true,
    );
  }

  @override
  late final ObservableState<T> value;
  @override
  late final ObservableState<bool> hasFocus = state(false);

  @override
  late final ObservableState<bool> wasEverUnfocused = state(false);
  @override
  late final ObservableState<bool> wasSetAfterFocus = state(false);
  @override
  late final ObservableState<bool> wasSet = state(false);
}
