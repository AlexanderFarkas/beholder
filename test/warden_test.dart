import 'package:flutter_test/flutter_test.dart';

import 'package:warden/warden.dart';

void main() {
  test('observable', () {
    final counter = ObservableState(0);
    var timesObserverIsCalled = 0;
    counter.addObserver(InlineObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 1;
    expect(counter.value, 1);
    expect(timesObserverIsCalled, 1);

    counter.update((previous) => previous + 1);
    expect(counter.value, 2);
    expect(timesObserverIsCalled, 2);
  });

  test('computed', () {
    final counter = ObservableState(0);
    final counter2 = ObservableState(100);
    final computed = ObservableComputed((watch) => watch(counter) + watch(counter2));

    var timesObserverIsCalled = 0;
    computed.addObserver(InlineObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 1;
    expect(counter.value, 1);
    expect(timesObserverIsCalled, 1);

    counter.update((previous) => previous + 1);
    expect(counter.value, 2);
    expect(timesObserverIsCalled, 2);

    counter.value = 1;
    counter2.value = 200;
    expect(computed.value, 201);
    expect(timesObserverIsCalled, 4);
  });

  test("deeply nested computed called once", () {
    final counter = ObservableState(0);
    late ObservableComputed previousComputed;
    for (int i = 0; i < 100; i++) {
      if (i == 0) {
        previousComputed = ObservableComputed((watch) => watch(counter));
      } else {
        final prev = previousComputed;
        previousComputed = ObservableComputed((watch) => watch(prev));
      }
    }

    var timesObserverIsCalled = 0;
    previousComputed.addObserver(InlineObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 4;
    expect(timesObserverIsCalled, 1);
    counter.value = 12;
    expect(timesObserverIsCalled, 2);
  });

  test("observable respects equals", () {
    final counter = ObservableState(0, equals: (a, b) => a == b);
    var timesObserverIsCalled = 0;
    counter.addObserver(InlineObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 2;
    expect(timesObserverIsCalled, 1);

    counter.value = 2;
    expect(timesObserverIsCalled, 1);
  });

  test("computed respects equals", () {
    final counter = ObservableState(0, equals: (a, b) => a == b);
    final computed = ObservableComputed((watch) => watch(counter), equals: (a, b) => a == b);

    var timesObserverIsCalled = 0;
    computed.addObserver(InlineObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 2;
    expect(timesObserverIsCalled, 1);

    counter.value = 2;
    expect(timesObserverIsCalled, 1);
  });

  test("several observers", () {
    final counter = ObservableState(0);
    var timesObserverIsCalled = 0;
    counter.addObserver(InlineObserver(() {
      timesObserverIsCalled++;
    }));
    counter.addObserver(InlineObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 2;
    expect(timesObserverIsCalled, 2);

    counter.value = 3;
    expect(timesObserverIsCalled, 4);
  });

  test("deeply nested observables", () {
    Observable.debugEnabled = true;
    final counter = ObservableState(0);
    final counter2 = ObservableState(100);
    final (rebuildCounter: rebuildCounter2, computed: doubledCounter) =
        createComputed((watch) => watch(counter) * 2);
    final (rebuildCounter: rebuildCounter3, computed: tripledCounter) =
        createComputed((watch) => watch(counter) * 3);
    final (rebuildCounter: rebuildCounter6, computed: counterMultipliedBy6) =
        createComputed((watch) {
      final doubled = watch(doubledCounter);
      final tripled = watch(tripledCounter);

      watch(counter2);

      final counterValue = watch(counter);
      return counterValue == 0 ? 0 : (doubled * tripled / counterValue);
    });

    expect([rebuildCounter2.value, rebuildCounter3.value, rebuildCounter6.value], [1, 1, 1]);
    expect([doubledCounter.value, tripledCounter.value, counterMultipliedBy6.value], [0, 0, 0]);

    counter.value++;
    expect([rebuildCounter2.value, rebuildCounter3.value, rebuildCounter6.value], [2, 2, 2]);
    expect([doubledCounter.value, tripledCounter.value, counterMultipliedBy6.value], [2, 3, 6]);

    counter.value = 10;
    expect([rebuildCounter2.value, rebuildCounter3.value, rebuildCounter6.value], [3, 3, 3]);
    expect([doubledCounter.value, tripledCounter.value, counterMultipliedBy6.value], [20, 30, 60]);

    counter2.value = 200;
    expect([rebuildCounter2.value, rebuildCounter3.value, rebuildCounter6.value], [3, 3, 4]);
    expect([doubledCounter.value, tripledCounter.value, counterMultipliedBy6.value], [20, 30, 60]);
  });

  test("Scoped update", () {
    final counter = ObservableState(10);
    final counter2 = ObservableState(100);

    final (:rebuildCounter, :computed) =
        createComputed((watch) => watch(counter) * watch(counter2));

    counter2.value = 200;
    counter.value = 20;
    expect(rebuildCounter.value, 3);

    final (rebuildCounter: rebuildCounter2, computed: computed2) =
        createComputed((watch) => watch(counter) * watch(counter2));

    scopedUpdate(() {
      counter2.value = 300;
      counter.value = 30;
    });
    expect(rebuildCounter2.value, 2);
  });

  test("Listeners are not updated after dispose", () {
    final counter = ObservableState(10);
    final computed = ObservableComputed((watch) => watch(counter) * 10);

    counter.dispose();
    counter.value = 20;
    expect(computed.value, 100);
  });
}

({RebuildCounter rebuildCounter, ObservableComputed<T> computed}) createComputed<T>(
    T Function(Observe watch) compute) {
  final rebuildCounter = RebuildCounter();
  return (
    rebuildCounter: rebuildCounter,
    computed: ObservableComputed<T>((watch) {
      rebuildCounter.increase();
      return compute(watch);
    })
  );
}

class RebuildCounter {
  int value = 0;
  void increase() {
    value++;
  }
}
