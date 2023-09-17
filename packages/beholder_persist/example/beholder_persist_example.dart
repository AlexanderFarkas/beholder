import 'package:beholder/beholder.dart';
import 'package:beholder_persist/beholder_persist.dart';

class InMemoryStorage implements PersistentStorage {
  final _storage = {};

  @override
  TValue? read<TValue>(String key) {
    return _storage[key];
  }

  @override
  void write<TValue>(String key, TValue value) {
    _storage[key] = value;
  }
}

class CounterViewModel extends ViewModel {
  late final counter = state(0)..persistAs("counter");

  void increment() => counter.value++;
}

void main() {
  PersistPlugin.storage = InMemoryStorage();
  var viewModel = CounterViewModel();
  viewModel.increment();
  print(viewModel.counter.value); // 1
  viewModel.dispose();

  viewModel = CounterViewModel();
  viewModel.increment();
  print(viewModel.counter.value); // 2
}
