import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    ObservableContext.reset();
  });

  testWidgets("Test", (tester) async {
    final vm = TestVm();
    await tester.pumpWidget(MaterialApp(
      home: Observer(
        builder: (context, watch) => Column(
          children: [
            Text("tab: ${watch(vm.tab)}"),
            Text("subject: ${watch(vm.subject)}"),
            Text("subjectDisplayError: ${watch(vm.subjectDisplayError)}"),
            Text("message: ${watch(vm.message)}"),
            Text("messageDisplayError: ${watch(vm.messageDisplayError)}"),
            Text("checked: ${watch(vm.checked)}"),
            Text("isSubmittable: ${watch(vm.isSubmittable)}"),
          ],
        ),
      ),
    ));
    vm.tab.value = TabBarState.rightSelected;
    await tester.pumpAndSettle();
    expect(find.text("tab: TabBarState.rightSelected"), findsOneWidget);

    vm.message.value = "d";
    await tester.pumpAndSettle();
    expect(find.text("message: d"), findsOneWidget);
  });
}

enum TabBarState {
  leftSelected,
  rightSelected,
}

class TestVm extends ViewModel {
  late final tab = state(TabBarState.leftSelected);
  late final subject = state("");
  late final subjectDisplayError =
      computed((watch) => watch(subject).isNotEmpty || !watch(checked) ? null : "Required");

  late final message = state("");
  late final messageDisplayError =
      computed((watch) => watch(message).isNotEmpty || !watch(checked) ? null : "Required");

  late final checked = state(false);

  late final isSubmittable = computed((watch) {
    final tab = watch(this.tab);
    final subjectDisplayError = watch(this.subjectDisplayError);
    final messageDisplayError = watch(this.messageDisplayError);
    return watch(checked);
  });
}
