import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:warden/warden.dart';

mixin FormMixin on ViewModel {
  Field<T> field<T>(
    T initialValue, {
    ComputeError<T>? computeError,
    String? Function(T value)? validate,
  }) {
    final field = Field(
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

        log(error ?? "null");
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

  late final fields = state<UnmodifiableSetView<Field>>(UnmodifiableSetView({}));
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

class FieldState<T> extends ViewModel {
  FieldState(T initialValue) {
    value = state(initialValue);
    value.listen(
      phase: ScopePhase.markNeedsUpdate,
      (value) {
        _wasSet.value = true;
        if (hasFocus.value) {
          _wasSetAfterFocus.value = true;
        }
      },
    );
    hasFocus.listen(phase: ScopePhase.markNeedsUpdate, (isFocused) {
      _wasSetAfterFocus.value = false;
      if (!isFocused) {
        _wasEverUnfocused.value = true;
      }
    });
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

typedef ComputeError<T> = String? Function(Watch watch, FieldState<T> state);

class Field<T> extends ViewModel implements WritableObservable<T> {
  Field(
    T value, {
    required this.computeError,
  }) {
    fieldState = FieldState(value);
    fieldState.value.listen(phase: ScopePhase.markNeedsUpdate, (value) {
      this._innerError.value = null;
    });
    disposers.add(fieldState.dispose);
  }

  late final FieldState<T> fieldState;
  late final _innerError = state<String?>(null);
  late final error = writableComputed(
    get: (watch) {
      final innerError = watch(_innerError);
      if (innerError != null) {
        return innerError;
      }

      return this.computeError(
        watch,
        fieldState,
      );
    },
    set: (value) {
      _innerError.value = value;
    },
  );
  late final ComputeError<T> computeError;

  @override
  void addObserver(ObserverMixin observer) => fieldState.value.addObserver(observer);

  @override
  Stream<T> asStream() => fieldState.value.asStream();

  @override
  Dispose listen(void Function(T value) onChanged) => fieldState.value.listen(onChanged);

  @override
  UnmodifiableSetView<ObserverMixin> get observers => fieldState.value.observers;

  @override
  void removeObserver(ObserverMixin observer) => fieldState.value.removeObserver(observer);

  @override
  T get value => fieldState.value.value;

  @override
  set value(T value) => fieldState.value.value = value;
}
