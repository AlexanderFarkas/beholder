import 'package:beholder/beholder.dart';
import 'package:beholder_persist/beholder_persist.dart';
import 'package:test/test.dart';

class InMemoryStorage extends PersistentStorage {
  var storage = {};

  @override
  TValue read<TValue>(String key) => storage[key];

  @override
  void write<TValue>(String key, TValue value) {
    storage[key] = value;
  }
}

class CounterViewModel extends ViewModel {
  late final counter = state(0)..persist("counter");

  void increment() => counter.value++;
}

void main() {
  setUp(() {
    PersistPlugin.storage = InMemoryStorage();
  });

  test("Basic", () {
    var viewModel = CounterViewModel();
    viewModel.increment();
    expect(viewModel.counter.value, 1);
    viewModel.dispose();

    viewModel = CounterViewModel();
    expect(viewModel.counter.value, 1);

    viewModel.increment();
    expect(viewModel.counter.value, 2);
  });

  test("Duplicate key assertion", () {
    final viewModel = CounterViewModel();
    viewModel.increment();
    expect(viewModel.counter.value, 1);

    expect(() {
      final viewModel = CounterViewModel();
      viewModel.increment();
    }, throwsA(isA<AssertionError>()));
  });
}
