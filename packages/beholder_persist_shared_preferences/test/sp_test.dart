import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:beholder_persist/beholder_persist.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beholder_persist_shared_preferences/beholder_persist_shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPreferences extends Mock implements SharedPreferences {
  final map = <String, dynamic>{};

  @override
  Object? get(String key) {
    final res = map[key];
    return res;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    map[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    map[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    map[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    map[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    map[key] = value;
    return true;
  }
}

void main() {
  setUp(() {
    final prefs = MockPreferences();
    PersistPlugin.storage = SharedPreferencesStorage(prefs);
  });

  group("Primitives", () {
    test("double", () => testObservable(0.0, 1.0));
    test("bool", () => testObservable(false, true));
    test("int", () => testObservable(0, 1));
    test("string", () => testObservable("", "hello"));
    test("list of strings", () => testObservable([""], ["hello"]));
  });

  group("Custom", () {
    test("(int, int) Record", () {
      (PersistPlugin.storage as SharedPreferencesStorage).registerType<(int, int)>(
        serialize: (tuple) => "${tuple.$1},${tuple.$2}",
        deserialize: (string) {
          final parts = string.split(",");
          return (int.parse(parts[0]), int.parse(parts[1]));
        },
      );

      testObservable((1, 2), (2, 3));
    });
  });
}

void testObservable<T>(T initialValue, T expectedValue) {
  var counter = ObservableState(initialValue)..persist('counter');
  counter.value = expectedValue;
  counter.dispose();
  counter = ObservableState(initialValue)..persist('counter');
  expect(counter.value, expectedValue);
  counter.dispose();
}
