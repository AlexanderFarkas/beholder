import 'package:flutter_test/flutter_test.dart';

import 'package:warden/warden.dart';

void main() {
  test('observable', () {
    final counter = ObservableValue(0);
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
    final counter = ObservableValue(0);
    final counter2 = ObservableValue(100);
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
    final counter = ObservableValue(0);
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
    final counter = ObservableValue(0, equals: (a, b) => a == b);
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
    final counter = ObservableValue(0, equals: (a, b) => a == b);
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
    final counter = ObservableValue(0);
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
}
