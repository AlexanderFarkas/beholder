import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:beholder_form/src/form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ObservableContext.reset();
  });

  test('Basic', () {
    final field = ObservableField(
      1,
      validate: (value) => value > 1 ? null : "error",
    );

    expect(field.value, equals(1));
    expect(field.error.value, equals("error"));
    expect(field.displayError.value, equals("error"));

    field.value = 2;
    expect(field.value, equals(2));
    expect(field.error.value, equals(null));
    expect(field.displayError.value, equals(null));

    field.error.value = "forced";
    expect(field.error.value, equals("forced"));
    expect(field.displayError.value, equals("forced"));
  });

  test('Basic Text', () {
    final field = ObservableTextField(
      "",
      validate: (value) => value.length > 1 ? null : "error",
    );

    expect(field.value, equals(''));
    expect(field.error.value, equals("error"));
    expect(field.displayError.value, equals("error"));

    field.value = "ha";
    expect(field.value, equals("ha"));
    expect(field.error.value, equals(null));
    expect(field.displayError.value, equals(null));

    field.error.value = "forced";
    expect(field.error.value, equals("forced"));
    expect(field.displayError.value, equals("forced"));
  });

  test("Controller", () {
    final field = ObservableTextField(
      "",
      validate: (value) => value.length > 1 ? null : "error",
    );

    field.controller.text = "ha";
    expect(field.value, equals("ha"));
    expect(field.error.value, equals(null));
    expect(field.displayError.value, equals(null));
  });

  test("Internal error", () {
    final field = ObservableField(
      "",
      validate: (value) => value.length > 1 ? null : "error",
    );

    field.error.value = "forced";
    expect(field.error.value, equals("forced"));

    field.value = "H";
    expect(field.error.value, equals("error"));
  });

  test("Internal error 2", () {
    final field = ObservableField(
      "",
      validate: (value) => value.length > 1 ? null : "error",
    );

    field.error.value = "forced";
    expect(field.error.value, equals("forced"));

    field.value = "Hello";
    expect(field.error.value, equals(null));
  });

  testWidgets("Focus", (tester) async {
    final focusNode = FocusNode();
    final field = ObservableTextField(
      "",
      validate: (value) => value.length < 3 ? "Min 3" : null,
      focusNode: () => focusNode,
    );

    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: TextField(
          focusNode: focusNode,
          controller: field.controller,
        ),
      ),
    ));

    field.test(
      wasEverChanged: false,
      wasEverUnfocused: false,
      hasFocus: false,
      wasChangedWhileFocused: false,
    );

    focusNode.requestFocus();
    await tester.pump();
    field.test(
      wasEverChanged: false,
      wasEverUnfocused: false,
      hasFocus: true,
      wasChangedWhileFocused: false,
    );

    field.value = "h";
    field.test(
      wasEverChanged: true,
      wasEverUnfocused: false,
      hasFocus: true,
      wasChangedWhileFocused: true,
    );
    focusNode.unfocus();
    await tester.pump();
    field.test(
      wasEverChanged: true,
      wasEverUnfocused: true,
      hasFocus: false,
      wasChangedWhileFocused: true,
    );

    focusNode.requestFocus();
    await tester.pump();
    field.test(
      wasEverChanged: true,
      wasEverUnfocused: true,
      hasFocus: true,
      wasChangedWhileFocused: false,
    );
  });
}

extension<T> on Field<T> {
  void test({
    required bool wasEverChanged,
    required bool wasEverUnfocused,
    required bool hasFocus,
    required bool wasChangedWhileFocused,
  }) {
    expect(this.wasEverChanged.value, equals(wasEverChanged));
    expect(this.wasEverUnfocused.value, equals(wasEverUnfocused));
    expect(this.hasFocus.value, equals(hasFocus));
    expect(this.wasChangedWhileFocused.value, equals(wasChangedWhileFocused));
  }
}
