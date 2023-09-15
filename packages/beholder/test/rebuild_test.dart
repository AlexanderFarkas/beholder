import 'package:flutter_test/flutter_test.dart';
import 'package:beholder/beholder.dart';

import 'utils.dart';

void main() {
  test("Rebuild count doesn't increase after sequential calls to value", () async {
    final counter = ObservableState(0);
    final doubled = createComputed((watch) => watch(counter) * 2);
    final tripled = createComputed((watch) => watch(counter) * 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [1, 1]);
    counter.value++;
    expect(doubled.computed.value, 2);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [2, 1]);
    expect(tripled.computed.value, 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [2, 2]);
    expect(doubled.computed.value, 2);
    expect(tripled.computed.value, 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [2, 2]);
  });

  test(
      "Rebuild count doesn't increase after sequential calls to value, even after scheduled update",
      () async {
    final counter = ObservableState(0);
    final doubled = createComputed((watch) => watch(counter) * 2);
    final tripled = createComputed((watch) => watch(counter) * 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [1, 1]);
    counter.value++;
    await ObservableScope.waitForUpdate();
    expect(doubled.computed.value, 2);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [2, 1]);
    expect(tripled.computed.value, 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [2, 2]);
    expect(doubled.computed.value, 2);
    expect(tripled.computed.value, 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [2, 2]);
  });

  test("Computed is not rebuilt if it doesn't have listeners", () async {
    final counter = ObservableState(0);
    final doubled = createComputed((watch) => watch(counter) * 2);

    expect(doubled.rebuildCounter.value, equals(1));
    counter.value++;
    await ObservableScope.waitForUpdate();
    expect(doubled.rebuildCounter.value, equals(1));
  });

  test("Listener is only rebuilt once, even if several observables have rebuilt", () async {
    final counter1 = ObservableState(0);
    final counter2 = ObservableState(0);

    final sum = createComputed((watch) => (watch(counter1), watch(counter2)));
    sum.computed.listen((value) {});

    expect(sum.rebuildCounter.value, equals(1));
    counter1.value++;
    counter2.value++;
    await ObservableScope.waitForUpdate();
    expect(sum.rebuildCounter.value, equals(2));
  });

  test("Listener is rebuilt, even if added after observables updated", () async {
    final counter = ObservableState(0);
    final sum = createComputed((watch) => watch(counter));

    expect(sum.rebuildCounter.value, equals(1));
    counter.value++;
    sum.computed.listen((value) {});
    expect(sum.rebuildCounter.value, equals(1));
    await ObservableScope.waitForUpdate();
    counter.value++;
    await ObservableScope.waitForUpdate();
    expect(sum.rebuildCounter.value, equals(2));
  });
}
