import 'package:flutter/widgets.dart';

import 'form_mixin.dart';

class FieldFocusScope extends StatelessWidget {
  final Field field;
  final Widget child;

  const FieldFocusScope({super.key, required this.field, required this.child});

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      onFocusChange: (hasFocus) {
        field.fieldState.hasFocus.value = hasFocus;
      },
      child: child,
    );
  }
}
