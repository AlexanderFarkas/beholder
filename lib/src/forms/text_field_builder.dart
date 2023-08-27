part of form;

class TextFieldBuilder extends StatefulWidget {
  const TextFieldBuilder({
    super.key,
    this.controller,
    required this.field,
    required this.builder,
  });

  final ObservableField<String> field;
  final TextEditingController? controller;
  final Widget Function(BuildContext context, TextEditingController controller) builder;

  @override
  State<TextFieldBuilder> createState() => _TextFieldBuilderState();
}

class _TextFieldBuilderState extends State<TextFieldBuilder> {
  TextEditingController? controller;
  Dispose? removeFieldListener;
  @override
  void initState() {
    super.initState();
    final controller = this.controller = widget.controller ?? TextEditingController();
    _setControllerValue(widget.field.value);
    controller.addListener(_controllerListener);
    removeFieldListener = widget.field.listen(_setControllerValue);
  }

  @override
  void dispose() {
    final isOwningController = widget.controller == null;
    if (isOwningController) {
      controller?.dispose();
    }
    removeFieldListener?.call();
    controller?.removeListener(_controllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FieldFocusScope(
      field: widget.field,
      child: widget.builder(context, controller!),
    );
  }

  void _controllerListener() {
    widget.field.value = controller!.text;
  }

  void _setControllerValue(String value) {
    if (controller case var controller? when controller.text != value) {
      controller.value = TextEditingValue(
        text: widget.field.value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }
}
