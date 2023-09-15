import 'package:beholder/beholder.dart';

({RebuildCounter rebuildCounter, ObservableComputed<T> computed}) createComputed<T>(
    T Function(Watch watch) compute) {
  final rebuildCounter = RebuildCounter();
  final computed = ObservableComputed<T>((watch) {
    rebuildCounter.increase();
    return compute(watch);
  });
  return (
    rebuildCounter: rebuildCounter,
    computed: computed,
  );
}

class RebuildCounter {
  int value = 0;
  void increase() {
    value++;
  }
}
