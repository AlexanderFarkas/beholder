part of form;

mixin FormMixin on ViewModel {
  ObservableField<T> field<T>(
    T value, {
    Validate<T>? validate,
    ComputeError<T>? computeError,
    ComputeDisplayError<T>? displayError,
  }) {
    final field = ObservableField(
      value,
      validate: validate,
      computeError: computeError,
      displayError: (watch, field) => interceptDisplayError(
        watch,
        field,
        displayError ?? defaultDisplayError,
      ),
    );
    trackField(field);
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
    return field;
  }

  @protected
  void trackField<T>(ObservableField<T> field) {
    disposers.add(field.dispose);
  }

  @protected
  String? interceptDisplayError<T>(
    Watch watch,
    Field<T> field,
    ComputeDisplayError<T> inner,
  ) {
    return inner(watch, field);
  }
}
