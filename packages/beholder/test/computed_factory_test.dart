import 'package:beholder/beholder.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test("Basic", () {
    final multipliedFactory = _factory();

    expect(multipliedFactory(2).value, equals(4));
    expect(multipliedFactory(4).value, equals(8));
  });

  test("Cache", () {
    final multipliedFactory = _factory();

    expect(multipliedFactory(2) == multipliedFactory(2), equals(true));
  });

  test("Cache is cleared, if not listened", () async {
    final multipliedFactory = _factory();

    final computed = multipliedFactory(2);
    await Future.microtask(() {});
    final computed2 = multipliedFactory(2);
    expect(computed == computed2, equals(false));
  });

  test("Cache if listened", () async {
    final multipliedFactory = _factory();

    final computed = multipliedFactory(2);
    final disposeListen = computed.listen((previous, current) {});
    await Future.microtask(() {});
    final computed2 = multipliedFactory(2);
    expect(computed == computed2, equals(true));

    disposeListen();
    final computed3 = multipliedFactory(2);
    expect(computed == computed3, equals(false));
  });

  test("Cache is invalidated if EVERY observer unsubscribed", () {
    final multipliedFactory = _factory();

    final computed = multipliedFactory(2);
    final disposeListen1 = computed.listen((previous, current) {});
    final disposeListen2 = computed.listen((previous, current) {});

    disposeListen1();
    final computed2 = multipliedFactory(2);
    expect(computed == computed2, equals(true));

    disposeListen2();
    final computed3 = multipliedFactory(2);
    expect(computed == computed3, equals(false));
  });

  test("Immediate disposal", () {
    final multipliedFactory = _factory();
    final c1 = multipliedFactory(2);
    c1.dispose();
    final c2 = multipliedFactory(2);
    expect(c1 == c2, equals(false));
  });

  test("Async gap disposal", () async {
    final multipliedFactory = _factory();
    final c1 = multipliedFactory(2);
    c1.dispose();
    await Future.microtask(() {});
    final c2 = multipliedFactory(2);
    expect(c1 == c2, equals(false));
  });

  test("Async gap disposal with listen", () async {
    final multipliedFactory = _factory();
    final c1 = multipliedFactory(2);
    final disposeListen = c1.listen((previous, current) {});
    c1.dispose();
    await Future.microtask(() {});
    final c2 = multipliedFactory(2);
    expect(c1 == c2, equals(false));
    disposeListen();
    final c3 = multipliedFactory(2);
    expect(c1 == c3, equals(false));
  });

  test("Async gap disposal with listen and multiple observers", () async {
    final multipliedFactory = _factory();
    final c1 = multipliedFactory(2);
    final disposeListen1 = c1.listen((previous, current) {});
    final disposeListen2 = c1.listen((previous, current) {});
    c1.dispose();
    await Future.microtask(() {});
    final c2 = multipliedFactory(2);
    expect(c1 == c2, equals(false));
    disposeListen1();
    final c3 = multipliedFactory(2);
    expect(c1 == c3, equals(false));
    disposeListen2();
    final c4 = multipliedFactory(2);
    expect(c1 == c4, equals(false));
  });
}

ComputedFactory<int, int> _factory() {
  final observable = ObservableState(2);
  final multipliedFactory = ComputedFactory((watch, int param) => watch(observable) * param);
  return multipliedFactory;
}
