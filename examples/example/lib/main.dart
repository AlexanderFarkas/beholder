import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/material.dart';

class AnotherVm extends ViewModel {
  late final counter = state(0);
  void increment() {
    counter.update((previous) => previous + 5);
  }
}

class WardenVm extends ViewModel {
  final AnotherVm anotherVm;

  late final counter = state(0);
  late final sum = computed((_) => _(counter) + _(anotherVm.counter));

  WardenVm(this.anotherVm);
  void increment() {
    counter.update((previous) => previous + 5);
  }
}

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final anotherVm = AnotherVm();

  @override
  void dispose() {
    anotherVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(anotherVm: anotherVm),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AnotherVm anotherVm;
  const HomeScreen({Key? key, required this.anotherVm}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late var vm = WardenVm(widget.anotherVm);

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: widget.anotherVm.increment,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) => SizedBox(
            width: 40,
            child: ListView.builder(itemBuilder: (_, index) {
              return SizedBox(
                height: 40,
                child: Observer(
                  builder: (context, watch) => Text("${watch(vm.sum)}"),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
