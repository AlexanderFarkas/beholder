import 'package:flutter/material.dart';
import 'package:warden/warden.dart';

class AnotherVm extends Store {
  late final counter = observable<num>(0);
  void increment() {
    counter.update((previous) => previous + 5);
  }
}

class WardenVm extends Store {
  final AnotherVm anotherVm;

  late final counter = observable(0);
  late final sum = computed((_) => _(counter) + _(anotherVm.counter));

  WardenVm(this.anotherVm);
  void increment() {
    counter.update((previous) => previous + 5);
  }
}

void main() {
  Observable.debugEnabled = true;
  runApp(App());
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
      key: UniqueKey(),
      home: HomeScreen(
        anotherVm: anotherVm,
      ),
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
  late final vm = WardenVm(widget.anotherVm);

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Warden(
              builder: (context, observe) {
                final value = observe(widget.anotherVm.counter);
                return OutlinedButton(
                  onPressed: widget.anotherVm.increment,
                  child: Text("another: $value"),
                );
              },
            ),
            Warden(
              builder: (context, observe) {
                final value = observe(vm.counter);
                return OutlinedButton(onPressed: vm.increment, child: Text("vm: $value"));
              },
            ),
            Warden(
              builder: (context, observe) {
                final value = observe(vm.sum);
                return Text("Sum: $value");
              },
            ),
          ],
        ),
      ),
    );
  }
}
