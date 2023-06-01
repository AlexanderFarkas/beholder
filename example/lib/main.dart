import 'package:flutter/material.dart';
import 'package:warden/warden.dart';
import 'package:warden/warden_mixin.dart';

class WardenVm extends Store {
  late final counter = observable(0);
  late final another2Counter =
      computed((watch) => (watch(anotherCounter), original: watch(counter)));
  late final anotherCounter = computed((watch) => (watch(counter), doubled: watch(doubledCounter)));
  late final doubledCounter = computed((watch) => watch(counter) * 2);

  WardenVm() {
    onDispose.add(another2Counter.stream.listen((value) => log("$value")).cancel);
  }

  void increment() {
    counter.update((previous) => previous + 5);
  }
}

void main() {
  Observable.debugEnabled = true;
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(key: UniqueKey(), home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final vm = WardenVm();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: vm.increment,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Warden(
              builder: (context, watch) {
                final value = watch(vm.another2Counter);
                return Text("$value");
              },
            ),
            Warden(
              builder: (context, watch) {
                final value = watch(vm.anotherCounter);
                return Text("$value");
              },
            ),
            Warden(
              builder: (context, watch) {
                final counter = watch(vm.counter);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Counter: $counter"),
                    Warden(
                      builder: (context, watch) => Text(
                        "Doubled Counter: ${watch(vm.doubledCounter)}",
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
