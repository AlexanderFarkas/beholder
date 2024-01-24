import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  setUp(() {
    ObservableContext.reset();
  });

  test("Rebuild count doesn't increase after sequential calls to value", () async {
    final counter = RootObservableState(0);
    final doubled = createComputed((watch) => watch(counter) * 2);
    final tripled = createComputed((watch) => watch(counter) * 3);

    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [0, 0]);
    counter.value++;
    expect(doubled.computed.value, 2);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [1, 0]);
    expect(tripled.computed.value, 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [1, 1]);
    expect(doubled.computed.value, 2);
    expect(tripled.computed.value, 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [1, 1]);
  });

  test(
      "Rebuild count doesn't increase after sequential calls to value, even after scheduled update",
      () async {
    final counter = RootObservableState(0);
    final doubled = createComputed((watch) => watch(counter) * 2);
    final tripled = createComputed((watch) => watch(counter) * 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [0, 0]);
    counter.value++;
    await ObservableContext.pump();
    expect(doubled.computed.value, 2);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [1, 0]);
    expect(tripled.computed.value, 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [1, 1]);
    expect(doubled.computed.value, 2);
    expect(tripled.computed.value, 3);
    expect([doubled.rebuildCounter.value, tripled.rebuildCounter.value], [1, 1]);
  });

  test("Computed is not rebuilt if it doesn't have listeners", () async {
    final counter = RootObservableState(0);
    final doubled = createComputed((watch) => watch(counter) * 2);

    counter.value++;
    await ObservableContext.pump();
    expect(doubled.rebuildCounter.value, equals(0));
  });

  test("Listener is only rebuilt once, even if several observables have rebuilt", () async {
    final counter1 = RootObservableState(0);
    final counter2 = RootObservableState(0);

    final sum = createComputed((watch) => (watch(counter1), watch(counter2)));
    sum.computed.listen((_, value) {});

    expect(sum.rebuildCounter.value, equals(1));
    counter1.value++;
    counter2.value++;
    await ObservableContext.pump();
    expect(sum.rebuildCounter.value, equals(2));
  });

  test("Listener is rebuilt, even if added after observables updated", () async {
    final counter = RootObservableState(0);
    final sum = createComputed((watch) => watch(counter));

    counter.value++;
    sum.computed.listen((_, value) {});
    expect(sum.rebuildCounter.value, equals(1));
    await ObservableContext.pump();
    counter.value++;
    await ObservableContext.pump();
    expect(sum.rebuildCounter.value, equals(2));
  });

  test("Name 1", () async {
    final counter = RootObservableState(0);
    final other = RootObservableState(100);
    final doubled = createComputed((watch) => watch(counter) * 2);

    var listened = -1;
    doubled.computed.listen((_, value) {
      listened = value;
    });

    counter.value++;
    expect(doubled.computed.value, equals(2));
    other.value = 200;

    await ObservableContext.pump();
    expect(listened, equals(2));
  });

  test("Name 2", () async {
    final counter = RootObservableState(0);
    final other = RootObservableState(100);
    final doubled = createComputed((watch) => watch(counter) * 2);

    var listened = -1;
    doubled.computed.listen((_, value) {
      listened = value;
    });

    counter.value++;
    expect(doubled.computed.value, equals(2));
    other.value = 200;

    await ObservableContext.pump();
    counter.value++;
    expect(doubled.computed.value, equals(4));
    other.value = 300;

    await ObservableContext.pump();
    expect(listened, equals(4));
  });
}
