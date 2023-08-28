import 'package:flutter/material.dart';
import 'package:warden/warden.dart';

void main() async {
  final fieldProvider = ObservableState("");
  final internalErrorProvider = ObservableState<String?>("internal");
  final errorProvider = ObservableComputed((ref) {
    final internalError = ref(internalErrorProvider);
    if (internalError != null) {
      return internalError;
    }
    return ref(fieldProvider).length < 8 ? "Min 8" : null;
  });

  String? errorInConsumer = errorProvider.value;

  fieldProvider.listen(
    phase: ScopePhase.markNeedsUpdate,
    (value) {
      internalErrorProvider.value = null;
    },
  );

  errorProvider.listen((value) {
    print("$value");
    errorInConsumer = value;
  });

  internalErrorProvider.value = "Internal error";
  fieldProvider.value = List.generate(7, (index) => "a").join();
  await Future(() {});
  print(errorInConsumer);
  assert(errorInConsumer == "Min 8");

  fieldProvider.value = List.generate(8, (index) => "a").join();
  await Future(() {});

  assert(errorInConsumer == null, "2");

  internalErrorProvider.value = "Internal error";
  fieldProvider.value = List.generate(7, (index) => "a").join();
  await Future(() {});
  assert(errorInConsumer == "Min 8", "3");

  fieldProvider.value = List.generate(7, (index) => "a").join();
  await Future(() {});
  assert(errorInConsumer == "Min 8", "4");

  fieldProvider.value = List.generate(8, (index) => "a").join();
  await Future(() {});
  assert(errorInConsumer == null, "5");
}

//
// class AnotherVm extends ViewModel {
//   late final counter = state<num>(0);
//   void increment() {
//     counter.update((previous) => previous + 5);
//   }
// }
//
// class WardenVm extends ViewModel {
//   final AnotherVm anotherVm;
//
//   late final counter = state(0);
//   late final sum = computed((_) => _(counter) + _(anotherVm.counter));
//
//   WardenVm(this.anotherVm);
//   void increment() {
//     counter.update((previous) => previous + 5);
//   }
// }
//
// void main() {
//   Observable.debugEnabled = true;
//   runApp(const App());
// }
//
// class App extends StatefulWidget {
//   const App({Key? key}) : super(key: key);
//
//   @override
//   State<App> createState() => _AppState();
// }
//
// class _AppState extends State<App> {
//   final anotherVm = AnotherVm();
//
//   @override
//   void dispose() {
//     anotherVm.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       key: UniqueKey(),
//       home: HomeScreen(
//         anotherVm: anotherVm,
//       ),
//     );
//   }
// }
//
// class HomeScreen extends StatefulWidget {
//   final AnotherVm anotherVm;
//   const HomeScreen({Key? key, required this.anotherVm}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   late final vm = WardenVm(widget.anotherVm);
//
//   @override
//   void dispose() {
//     vm.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: widget.anotherVm.increment,
//         child: const Icon(Icons.add),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Observer(
//               builder: (context, observe) {
//                 final value = observe(widget.anotherVm.counter);
//                 return OutlinedButton(
//                   onPressed: widget.anotherVm.increment,
//                   child: Text("another: $value"),
//                 );
//               },
//             ),
//             Observer(
//               builder: (context, observe) {
//                 final value = observe(vm.counter);
//                 return OutlinedButton(onPressed: vm.increment, child: Text("vm: $value"));
//               },
//             ),
//             Observer(
//               builder: (context, observe) {
//                 final value = observe(vm.sum);
//                 return Text("Sum: $value");
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
