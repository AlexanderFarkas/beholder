part of form;

mixin FormMixin on ViewModel {
  ObservableField<T> field<T>(
    T value, {
    required Validate<T> validate,
    ComputeError<T>? computeError,
    ComputeDisplayError<T>? displayError,
  }) {
    final field = ObservableField(
      value,
      validate: validate,
      computeError: computeError,
      displayError: (watch, state) => interceptDisplayError(
        watch,
        state,
        displayError ?? defaultDisplayError,
      ),
    );
    _trackField(field);
    return field;
  }

  ObservableTextField textField(
    String value, {
    Validate<String>? validate,
    ComputeError<String>? computeError,
    ComputeDisplayError<String>? displayError,
  }) {
    final field = ObservableTextField(
      value,
      validate: validate,
      computeError: computeError,
      displayError: (watch, state) => interceptDisplayError(
        watch,
        state,
        displayError ?? defaultDisplayError,
      ),
    );
    _trackField(field);
    return field;
  }

  void _trackField<T>(ObservableField<T> field) {
    fields.add(field);
    disposers.add(field.dispose);
  }

  final fields = <ObservableField>{};

  @protected
  String? interceptDisplayError<T>(
    Watch watch,
    FieldState<T> state,
    ComputeDisplayError<T> inner,
  ) {
    return inner(watch, state);
  }
}
