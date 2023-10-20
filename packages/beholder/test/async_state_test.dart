// import 'package:beholder/beholder.dart';
// import 'package:test/test.dart';

// import 'utils.dart';

void main() {
  // setUp(() {
  //   ObservableScope.reset();
  // });

  // test("Standard", () async {
  //   final asyncState = ObservableAsyncState<String>(value: const Loading());
  //   asyncState.scheduleRefresh((_) async => "value");
  //   expect(asyncState.value, equals(const Loading<String>()));
  //   await ObservableScope.pump();
  //   expect(asyncState.value, equals(const Success("value")));
  // });

  // test("Loading with previous", () async {
  //   final asyncState = ObservableAsyncState<String>(value: const Success("another"));
  //   asyncState.scheduleRefresh((_) async => "value");
  //   expect(asyncState.value, equals(const Loading(previousResult: Success("another"))));
  //   await ObservableScope.pump();
  //   expect(asyncState.value, equals(const Success("value")));
  // });

  // test("Loading with skip previous", () async {
  //   final asyncState = ObservableAsyncState<String>(value: const Success("another"));
  //   asyncState.scheduleRefresh((_) async => "value");
  //   expect(asyncState.value, equals(const Loading(previousResult: Success("another"))));
  //   await ObservableScope.pump();
  //   expect(asyncState.value, equals(const Success("value")));
  // });

  // test("Set value before refresh end cancels future", () async {
  //   final asyncState = ObservableAsyncState<String>(value: const Success("another"));
  //   asyncState.scheduleRefresh((_) async => "value");
  //   asyncState.value = const Success("another value");
  //   expect(asyncState.value, equals(const Success("another value")));
  //   await ObservableScope.pump();
  //   expect(asyncState.value, equals(const Success("another value")));
  // });

  // test("Several refreshes", () async {
  //   final asyncState = ObservableAsyncState<String>(
  //     value: const Loading(),
  //   );
  //   asyncState.scheduleRefresh((_) async => "value1");
  //   asyncState.scheduleRefresh((_) async => "value2");
  //   asyncState.scheduleRefresh((_) async => "value3");
  //   expect(asyncState.value, equals(const Loading<String>()));
  //   await ObservableScope.pump();
  //   expect(asyncState.value, equals(const Success("value3")));
  // });

  // test("Debounce", () async {
  //   const duration = Duration(milliseconds: 10);
  //   final asyncState = ObservableAsyncState<String>(
  //     value: const Loading(),
  //     debounceTime: duration,
  //   );
  //   asyncState.scheduleRefresh((_) async => "value1");
  //   asyncState.scheduleRefresh((_) async => "value2");
  //   asyncState.scheduleRefresh((_) async => "value3");
  //   expect(asyncState.value, equals(const Loading<String>()));
  //   await ObservableScope.pump();
  //   expect(asyncState.value, equals(const Loading<String>()));
  //   await Future.delayed(duration);
  //   await ObservableScope.pump();
  //   expect(asyncState.value, equals(const Success("value3")));
  // });

  // test("Throttle", () async {
  //   const duration = Duration(milliseconds: 10);
  //   final asyncState = ObservableAsyncState<String>(
  //     value: const Loading(),
  //     throttleTime: duration,
  //   );
  //   asyncState.scheduleRefresh((_) async => "value1");
  //   asyncState.scheduleRefresh((_) async => "value2");
  //   asyncState.scheduleRefresh((_) async => "value3");
  //   expect(asyncState.value, equals(const Loading<String>()));
  //   await ObservableScope.pump();
  //   expect(asyncState.value, equals(const Success("value1")));
  //   await Future.delayed(duration);
  //   asyncState.scheduleRefresh((_) async => "value4");
  //   await ObservableScope.pump();
  //   expect(asyncState.value, equals(const Success("value4")));
  // });

  // test("Respects default equals", () async {
  //   final asyncState = ObservableAsyncState<String>(value: const Loading());

  //   final trimmed = createComputed(
  //     (watch) => watch(asyncState).mapValue((value) => value.trim()),
  //   );
  //   trimmed.computed.listen((_, value) {});

  //   final value = "value";
  //   asyncState.value = Success(value);
  //   await ObservableScope.pump();
  //   asyncState.value = Success(value);
  //   await ObservableScope.pump();
  //   asyncState.value = Success(value);
  //   await ObservableScope.pump();
  //   asyncState.value = Success(value);
  //   await ObservableScope.pump();
  //   expect(trimmed.rebuildCounter.value, equals(2));
  // });

  // test("Respects equals", () async {
  //   final asyncState = ObservableAsyncState<String>(
  //     value: const Loading(),
  //     equals: (prev, next) => false, // rebuild always
  //   );

  //   final trimmed = createComputed(
  //     (watch) => watch(asyncState).mapValue((value) => value.trim()),
  //   );
  //   trimmed.computed.listen((_, value) {});

  //   final value = "value";
  //   asyncState.value = Success(value);
  //   await ObservableScope.pump();
  //   asyncState.value = Success(value);
  //   await ObservableScope.pump();
  //   asyncState.value = Success(value);
  //   await ObservableScope.pump();
  //   asyncState.value = Success(value);
  //   await ObservableScope.pump();
  //   expect(trimmed.rebuildCounter.value, equals(5));
  // });

  // test("Immediate throw", () async {
  //   final asyncState = ObservableAsyncState<String>(value: const Loading());
  //   asyncState.scheduleRefresh((_) async => "");
  //   asyncState.scheduleRefresh((_) => throw "error");
  //   expect(asyncState.value, equals(const Loading<String>()));
  //   await ObservableScope.pump();
  //   expect((asyncState.value as Failure).error, equals(const Failure<String>("error").error));
  // });
}
