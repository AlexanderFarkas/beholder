part of form;

mixin FormMixin on ViewModel {
  ObservableField<T> field<T>({
    required T initialValue,
    ComputeError<T>? computeError,
    String? Function(T value)? validate,
  }) {
    final field = ObservableField(
      initialValue,
      computeError: (watch, state) {
        final String? error;
        if (computeError != null) {
          error = computeError(watch, state);
        } else if (validate != null) {
          error = validate(watch(state.value));
        } else {
          error = null;
        }

        return errorInterceptor(
          watch,
          state,
          error,
        );
      },
    );
    fields.value = UnmodifiableSetView({...fields.value, field});
    disposers.add(field.dispose);
    return field;
  }

  late final fields = state<UnmodifiableSetView<ObservableField>>(UnmodifiableSetView({}));
  late final isValid = computed((watch) {
    final fields = watch(this.fields);
    for (final field in fields) {
      if (watch(field.error) != null) return false;
    }
    return true;
  });

  @protected
  String? errorInterceptor<T>(Watch watch, FieldState<T> state, String? error) {
    return error;
  }
}
