part of form;

abstract interface class FieldState<T> {
  Observable<T> get value;
  Observable<bool> get hasFocus;
  Observable<bool> get wasEverUnfocused;
  Observable<bool> get wasChangedAfterFocus;
  Observable<bool> get wasChanged;
}

class WritableFieldState<T> extends ViewModel implements FieldState<T> {
  WritableFieldState(T initialValue) {
    value = state(initialValue)
      ..listenSync((_, value) {
        wasChanged.value = true;
        if (hasFocus.value) {
          wasChangedAfterFocus.value = true;
        }
      });

    hasFocus.listenSync(
      (_, isFocused) {
        wasChangedAfterFocus.value = false;
        if (!isFocused) {
          wasEverUnfocused.value = true;
        }
      },
    );
  }

  @override
  late final ObservableState<T> value;
  @override
  late final ObservableState<bool> hasFocus = state(false);

  @override
  late final ObservableState<bool> wasEverUnfocused = state(false);
  @override
  late final ObservableState<bool> wasChangedAfterFocus = state(false);
  @override
  late final ObservableState<bool> wasChanged = state(false);
}
