import 'dart:async';

import 'package:beholder/beholder.dart';
import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const _CounterApp());
}

class CounterViewModel extends ViewModel {
  // Define mutable state
  late final count = state(0);

  // Mutate state
  void increment() => count.value++;
}

class CounterButton extends StatefulWidget {
  const CounterButton({super.key});

  @override
  State<CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton> {
  final vm = CounterViewModel();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context, watch) => ElevatedButton(
        onPressed: vm.increment,
        // Listen for changes with `watch`
        child: Text("${watch(vm.count)}"),
      ),
    );
  }
}

class _CounterApp extends StatelessWidget {
  const _CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: CounterButton(),
        ),
      ),
    );
  }
}
