import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test("Standard", () async {
    final asyncState = ObservableAsyncState<String>(value: const Loading());
    asyncState.scheduleRefresh(() async => "value");
    expect(asyncState.value, equals(const Loading<String>()));
    await ObservableScope.waitForUpdate();
    expect(asyncState.value, equals(const Success("value")));
  });

  test("Loading with previous", () async {
    final asyncState = ObservableAsyncState<String>(value: const Success("another"));
    asyncState.scheduleRefresh(() async => "value");
    expect(asyncState.value, equals(const Loading(previousResult: Success("another"))));
    await ObservableScope.waitForUpdate();
    expect(asyncState.value, equals(const Success("value")));
  });

  test("Loading with skip previous", () async {
    final asyncState = ObservableAsyncState<String>(value: const Success("another"));
    asyncState.scheduleRefresh(() async => "value");
    expect(asyncState.value, equals(const Loading(previousResult: Success("another"))));
    await ObservableScope.waitForUpdate();
    expect(asyncState.value, equals(const Success("value")));
  });

  test("Set value before refresh end cancels future", () async {
    final asyncState = ObservableAsyncState<String>(value: const Success("another"));
    asyncState.scheduleRefresh(() async => "value");
    asyncState.value = const Success("another value");
    expect(asyncState.value, equals(const Success("another value")));
    await ObservableScope.waitForUpdate();
    expect(asyncState.value, equals(const Success("another value")));
  });

  test("Several refreshes", () async {
    final asyncState = ObservableAsyncState<String>(
      value: const Loading(),
    );
    asyncState.scheduleRefresh(() async => "value1");
    asyncState.scheduleRefresh(() async => "value2");
    asyncState.scheduleRefresh(() async => "value3");
    expect(asyncState.value, equals(const Loading<String>()));
    await ObservableScope.waitForUpdate();
    expect(asyncState.value, equals(const Success("value3")));
  });

  test("Debounce", () async {
    const duration = Duration(milliseconds: 10);
    final asyncState = ObservableAsyncState<String>(
      value: const Loading(),
      debounceTime: duration,
    );
    asyncState.scheduleRefresh(() async => "value1");
    asyncState.scheduleRefresh(() async => "value2");
    asyncState.scheduleRefresh(() async => "value3");
    expect(asyncState.value, equals(const Loading<String>()));
    await ObservableScope.waitForUpdate();
    expect(asyncState.value, equals(const Loading<String>()));
    await Future.delayed(duration);
    await ObservableScope.waitForUpdate();
    expect(asyncState.value, equals(const Success("value3")));
  });

  test("Throttle", () async {
    const duration = Duration(milliseconds: 10);
    final asyncState = ObservableAsyncState<String>(
      value: const Loading(),
      throttleTime: duration,
    );
    asyncState.scheduleRefresh(() async => "value1");
    asyncState.scheduleRefresh(() async => "value2");
    asyncState.scheduleRefresh(() async => "value3");
    expect(asyncState.value, equals(const Loading<String>()));
    await ObservableScope.waitForUpdate();
    expect(asyncState.value, equals(const Success("value1")));
    await Future.delayed(duration);
    asyncState.scheduleRefresh(() async => "value4");
    await ObservableScope.waitForUpdate();
    expect(asyncState.value, equals(const Success("value4")));
  });

  test("Respects default equals", () async {
    final asyncState = ObservableAsyncState<String>(value: const Loading());

    final trimmed = createComputed(
      (watch) => watch(asyncState).mapValue((value) => value.trim()),
    );
    trimmed.computed.listen((value) {});

    final value = "value";
    asyncState.value = Success(value);
    await ObservableScope.waitForUpdate();
    asyncState.value = Success(value);
    await ObservableScope.waitForUpdate();
    asyncState.value = Success(value);
    await ObservableScope.waitForUpdate();
    asyncState.value = Success(value);
    await ObservableScope.waitForUpdate();
    expect(trimmed.rebuildCounter.value, equals(2));
  });

  test("Respects equals", () async {
    final asyncState = ObservableAsyncState<String>(
      value: const Loading(),
      equals: (prev, next) => false, // rebuild always
    );

    final trimmed = createComputed(
      (watch) => watch(asyncState).mapValue((value) => value.trim()),
    );
    trimmed.computed.listen((value) {});

    final value = "value";
    asyncState.value = Success(value);
    await ObservableScope.waitForUpdate();
    asyncState.value = Success(value);
    await ObservableScope.waitForUpdate();
    asyncState.value = Success(value);
    await ObservableScope.waitForUpdate();
    asyncState.value = Success(value);
    await ObservableScope.waitForUpdate();
    expect(trimmed.rebuildCounter.value, equals(5));
  });

  test("Immediate throw", () async {
    final asyncState = ObservableAsyncState<String>(value: const Loading());
    asyncState.scheduleRefresh(() async => "");
    asyncState.scheduleRefresh(() => throw "error");
    expect(asyncState.value, equals(const Loading<String>()));
    await ObservableScope.waitForUpdate();
    expect((asyncState.value as Failure).error, equals(const Failure<String>("error").error));
  });
}