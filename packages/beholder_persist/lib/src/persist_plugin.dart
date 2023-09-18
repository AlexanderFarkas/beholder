import 'package:beholder/beholder.dart';
import 'package:beholder_persist/src/persistent_storage.dart';
import 'package:meta/meta.dart';

class PersistPlugin<T> extends StatePlugin<T> {
  static late PersistentStorage storage;

  @visibleForTesting
  static final debugKeys = <String>{};

  final String key;

  PersistPlugin({required this.key});

  @override
  void onMounted(RootObservable<T> observable) {
    assert(() {
      return debugKeys.add(key);
    }(), "Duplicate key: $key. Persistence keys should be unique across the app.");

    final value = storage.read<T>(key);
    if (value == null) return;
    observable.value = value;
  }

  @override
  void onUnmounted(RootObservable<T> observable) {
    assert(() {
      debugKeys.remove(key);
      return true;
    }());
  }

  @override
  void onValueChanged(T value) {
    storage.write<T>(key, value);
  }
}

extension PersistPluginX<TValue> on RootObservable<TValue> {
  void persist(String globallyUniqueKey) {
    registerPlugin(PersistPlugin(key: globallyUniqueKey));
  }
}
