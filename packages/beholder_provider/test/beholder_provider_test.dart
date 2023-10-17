import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beholder_provider/beholder_provider.dart';
import 'package:provider/provider.dart';

class CounterVm extends ViewModel {
  late final counter = state(0);
}

void main() {
  testWidgets("description", (tester) async {
    late CounterVm viewModel;
    await tester.pumpWidget(
      ViewModelProvider(
        create: (_) {
          return viewModel = CounterVm();
        },
        builder: (context, $) {
          final viewModel = context.watch<CounterVm>();
          return MaterialApp(home: Text($(viewModel.counter).toString()));
        },
      ),
    );
    expect(find.text("0"), findsOneWidget);
    viewModel.counter.value++;
    await tester.pump();
    expect(find.text("1"), findsOneWidget);
  });
}
