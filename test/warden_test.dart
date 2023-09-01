import 'package:flutter_test/flutter_test.dart';

import 'package:warden/warden.dart';

import 'utils.dart';

void main() {
  setUp(() {
    ObservableScope.reset();
  });

  test('observable', () async {
    final counter = ObservableState(0);
    var timesObserverIsCalled = 0;
    counter.addObserver(ListenObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 1;
    expect(counter.value, 1);
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 1);

    counter.update((previous) => previous + 1);
    expect(counter.value, 2);
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 2);
  });

  test('computed', () async {
    Observable.debugEnabled = true;
    final counter = ObservableState(0);
    final counter2 = ObservableState(100);
    final computed = ObservableComputed((watch) => watch(counter) + watch(counter2));

    var timesObserverIsCalled = 0;
    computed.addObserver(ListenObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 1;
    expect(counter.value, 1);
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 1);

    counter.update((previous) => previous + 1);
    expect(counter.value, 2);
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 2);

    counter.value = 1;
    counter2.value = 200;
    expect(computed.value, 201);
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 3);
  });

  test("deeply nested computed called once", () async {
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
    previousComputed.addObserver(ListenObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 4;
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 1);
    counter.value = 12;
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 2);
  });

  test("observable respects equals", () async {
    final counter = ObservableState(0, equals: (a, b) => a == b);
    var timesObserverIsCalled = 0;
    counter.addObserver(ListenObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 2;
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 1);

    counter.value = 2;
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 1);
  });

  test("computed respects equals", () async {
    final counter = ObservableState(0, equals: (a, b) => a == b);
    final computed = ObservableComputed((watch) => watch(counter), equals: (a, b) => a == b);

    var timesObserverIsCalled = 0;
    computed.addObserver(ListenObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 2;
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 1);

    counter.value = 2;
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 1);
  });

  test("several observers", () async {
    final counter = ObservableState(0);
    var timesObserverIsCalled = 0;
    counter.addObserver(ListenObserver(() {
      timesObserverIsCalled++;
    }));
    counter.addObserver(ListenObserver(() {
      timesObserverIsCalled++;
    }));

    counter.value = 2;
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 2);

    counter.value = 3;
    await ObservableScope.waitForUpdate();
    expect(timesObserverIsCalled, 4);
  });

  test("deeply nested observables", () async {
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

    await ObservableScope.waitForUpdate();
    expect([doubledCounter.value, tripledCounter.value, counterMultipliedBy6.value], [0, 0, 0]);
    expect([rebuildCounter2.value, rebuildCounter3.value, rebuildCounter6.value], [1, 1, 1]);

    counter.value = 1;
    await ObservableScope.waitForUpdate();
    expect([doubledCounter.value, tripledCounter.value, counterMultipliedBy6.value], [2, 3, 6]);
    expect([rebuildCounter2.value, rebuildCounter3.value, rebuildCounter6.value], [2, 2, 2]);

    counter.value = 10;
    await ObservableScope.waitForUpdate();
    expect([doubledCounter.value, tripledCounter.value, counterMultipliedBy6.value], [20, 30, 60]);
    expect([rebuildCounter2.value, rebuildCounter3.value, rebuildCounter6.value], [3, 3, 3]);

    counter2.value = 200;
    await ObservableScope.waitForUpdate();
    expect([doubledCounter.value, tripledCounter.value, counterMultipliedBy6.value], [20, 30, 60]);
    expect([rebuildCounter2.value, rebuildCounter3.value, rebuildCounter6.value], [3, 3, 4]);
  });

  test("Scoped update", () async {
    final counter = ObservableState(10);
    final counter2 = ObservableState(100);

    final (:rebuildCounter, :computed) =
        createComputed((watch) => watch(counter) * watch(counter2));

    counter2.value = 200;
    counter.value = 20;
    await ObservableScope.waitForUpdate();
    expect(computed.value, 4000);
    expect(rebuildCounter.value, 2);

    final (rebuildCounter: rebuildCounter2, computed: computed2) =
        createComputed((watch) => watch(counter) * watch(counter2));

    counter2.value = 300;
    counter.value = 30;
    await ObservableScope.waitForUpdate();
    expect(computed2.value, 9000);
    expect(rebuildCounter2.value, 2);
  });

  test("Listeners are not updated after dispose", () {
    final counter = ObservableState(10);
    final computed = ObservableComputed((watch) => watch(counter) * 10);

    counter.dispose();
    counter.value = 20;
    expect(computed.value, 100);
  });

  group("namegroup", () {
    test("name", () {
      final username = ObservableState("");
      final usernameError =
          ObservableComputed((watch) => watch(username).length < 8 ? "Min 8" : null);
      final hasError = ObservableComputed((watch) => watch(usernameError) != null && false);

      final errorIfHasError = ObservableComputed((watch) {
        watch(hasError);
        final error = watch(usernameError);
        return error;
      });
      expect(errorIfHasError.value, "Min 8");
      username.value = List.generate(8, (index) => "a").join();
      expect(errorIfHasError.value, null);
    });
  });

  test("description", () async {
    Observable.debugEnabled = true;
    final internalError = ObservableState<String?>(null);
    final value = ObservableState("");
    value.listen(eager: true, (value) {
      internalError.value = null;
    });
    final error = ObservableComputed((watch) {
      if (watch(internalError) case var internalError?) {
        return internalError;
      }
      return watch(value).length < 8 ? "Min 8" : null;
    });

    var errorInConsumer = error.value;
    error.listen((value) {
      errorInConsumer = value;
    });

    expect(errorInConsumer, "Min 8");
    value.value = List.generate(8, (index) => "a").join();
    await ObservableScope.waitForUpdate();
    expect(errorInConsumer, null);
    internalError.value = "Internal error";
    await ObservableScope.waitForUpdate();
    expect(errorInConsumer, "Internal error");
    value.value = List.generate(7, (index) => "a").join();
    await ObservableScope.waitForUpdate();
    expect(errorInConsumer, "Min 8");
    value.value = List.generate(8, (index) => "a").join();
    await ObservableScope.waitForUpdate();
    expect(errorInConsumer, null);

    value.value = List.generate(7, (index) => "a").join();
    await ObservableScope.waitForUpdate();

    internalError.value = "Internal error";
    value.value = List.generate(8, (index) => "a").join();
    await ObservableScope.waitForUpdate();
    expect(errorInConsumer, null);
  });

  test("dsds", () async {
    Observable.debugEnabled = true;
    final internalError = ObservableState<String?>("internal");
    final value = ObservableState("");
    value.listen(eager: true, (value) {
      internalError.value = null;
    });
    final error = ObservableComputed((watch) {
      if (watch(internalError) case var internalError?) {
        return internalError;
      }
      final result = watch(value).length < 8 ? "Min 8" : null;
      return result;
    });

    var errorInConsumer = error.value;
    error.listen((value) {
      errorInConsumer = value;
    });

    internalError.value = "Internal error";
    value.value = List.generate(7, (index) => "a").join();
    await ObservableScope.waitForUpdate();
    expect(errorInConsumer, "Min 8");
  });

  test("dsd", () async {
    final doubledCounter = ObservableState(0);
    final counter = ObservableState(0)
      ..listen((value) {
        doubledCounter.value = value * 2;
      });

    var doubledCounterInListener = doubledCounter.value;
    doubledCounter.listen((value) {
      doubledCounterInListener = value;
    });
    counter.value = 2;
    await ObservableScope.waitForUpdate();
    await ObservableScope.waitForUpdate();
    expect(doubledCounterInListener, equals(4));
    expect(doubledCounter.value, equals(4));
    counter.value = 0;
    await ObservableScope.waitForUpdate();
    await ObservableScope.waitForUpdate();
    expect(doubledCounterInListener, equals(0));
    expect(doubledCounter.value, equals(0));
  });
}
