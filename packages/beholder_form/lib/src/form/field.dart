part of form;

typedef FocusNodeFactory = FocusNode Function();
typedef Validate<T> = String? Function(T value);
typedef ComputeDisplayError<T> = String? Function(Watch watch, FieldState<T> state);

typedef ComputeError<T> = String? Function(Watch watch, T value);

String? defaultDisplayError<T>(Watch watch, FieldState<T> state) {
  return watch(state.error);
}

abstract interface class FieldState<T> {
  Observable<String?> get error;
  Observable<bool> get wasEverUnfocused;
  Observable<bool> get wasEverChanged;
  Observable<bool> get wasChangedWhileFocused;
  Observable<bool> get hasFocus;
}

class ObservableField<T> extends ViewModel
    with ObservableStateProxyMixin<T>
    implements FieldState<T> {
  ObservableField(
    T value, {
    Validate<T>? validate,
    ComputeError<T>? computeError,
    ComputeDisplayError<T>? displayError,
    FocusNodeFactory? focusNode,
  })  : assert(validate == null || computeError == null),
        focusNode = focusNode?.call() ?? FocusNode(),
        _displayError = displayError ?? defaultDisplayError,
        _computeError = computeError ?? ((_, value) => validate?.call(value)),
        inner = ObservableState(value) {
    inner.listenSync((previous, next) {
      wasEverChanged.value = true;
      if (hasFocus.value) {
        wasChangedWhileFocused.value = true;
      }
      _internalError.value = null;
    });
    _everHadFocus = this.focusNode.hasFocus;
    this.focusNode.addListener(_focusNodeListener);
  }

  final FocusNode focusNode;
  final ComputeError<T> _computeError;
  final ComputeDisplayError<T> _displayError;

  @override
  late final WritableObservableComputed<String?> error = writableComputed(
    get: (watch) {
      final internalError = watch(_internalError);
      if (internalError != null) {
        return internalError;
      }
      return _computeError(watch, watch(inner));
    },
    set: (value) => _internalError.value = value,
  );

  late final displayError = computed((watch) => _displayError(watch, this));
  late final _internalError = state<String?>(null);

  @override
  final ObservableState<T> inner;

  @override
  late final ObservableState<bool> wasEverUnfocused = state(false);
  @override
  late final ObservableState<bool> wasEverChanged = state(false);
  @override
  late final ObservableState<bool> wasChangedWhileFocused = state(false);
  @override
  late final ObservableState<bool> hasFocus = state(focusNode.hasFocus);

  @override
  void dispose() {
    focusNode.dispose();
    inner.dispose();
    super.dispose();
  }

  late bool _everHadFocus;

  void _focusNodeListener() {
    hasFocus.value = focusNode.hasFocus;
    if (focusNode.hasFocus) {
      _everHadFocus = true;
      wasChangedWhileFocused.value = false;
    }

    if (!focusNode.hasFocus && _everHadFocus) {
      wasEverUnfocused.value = true;
    }
  }
}
