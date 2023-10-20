```dart
class CounterVm extends ViewModel {
  late final counter = state(0);
}

Widget build(BuildContext context) => ViewModelProvider(
  create: (_) => CounterVm(),
  builder: (context, watch) {
    return Text('${watch(counter)}');
  }
);
```