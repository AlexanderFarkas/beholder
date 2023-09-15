part of form;

class FieldObserver extends StatefulWidget {
  const FieldObserver({
    super.key,
    this.controller,
    required this.field,
    required this.builder,
  });

  final WritableObservableField<String> field;
  final TextEditingController? controller;
  final Widget Function(BuildContext context, Watch watch, TextEditingController controller)
      builder;

  @override
  State<FieldObserver> createState() => _FieldObserverState();
}

class _FieldObserverState extends State<FieldObserver> {
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
      child: Observer(
        builder: (context, watch) => widget.builder(context, watch, controller!),
      ),
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
