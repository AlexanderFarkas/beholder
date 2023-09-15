part of form;

class FieldFocusScope extends StatelessWidget {
  final WritableObservableField field;
  final Widget child;

  const FieldFocusScope({super.key, required this.field, required this.child});

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      onFocusChange: (hasFocus) {
        field._fieldState.hasFocus.value = hasFocus;
      },
      child: child,
    );
  }
}
