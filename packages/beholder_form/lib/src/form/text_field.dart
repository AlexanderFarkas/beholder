part of form;

typedef ControllerFactory = TextEditingController Function(String initialValue);

class ObservableTextField extends ObservableField<String> {
  ObservableTextField(
    super.value, {
    super.validate,
    super.computeError,
    super.displayError,
    ControllerFactory? controller,
    super.focusNode,
  }) : super() {
    _controller = ObservableNotifier(
      () => controller?.call(value) ?? TextEditingController(text: value),
    )..listenSync((previous, current) => inner.value = current.text);
  }

  late final ObservableNotifier<TextEditingValue, TextEditingController>
      _controller;

  TextEditingController get controller => _controller.notifier;
  
  @override
  bool setValue(String value) {
    return _controller.setValue(TextEditingValue.empty.copyWith(text: value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
