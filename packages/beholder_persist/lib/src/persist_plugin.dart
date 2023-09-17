import 'package:beholder/beholder.dart';
import 'package:beholder_persist/src/persistent_storage.dart';
import 'package:meta/meta.dart';

class PersistPlugin<T> extends StatePlugin<T> {
  static late final PersistentStorage storage;

  @visibleForTesting
  static final debugKeys = <String>{};

  final String key;

  PersistPlugin({required this.key});

  @override
  void onMounted(RootObservable<T> observable) {
    assert(() {
      return debugKeys.add(key);
    }(), "Duplicate key: $key. Persistence keys should be unique across the app.");

    final value = storage.read(key);
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
    storage.write(key, value);
  }
}

extension PersistPluginX<TValue> on RootObservable<TValue> {
  void persistAs(String globallyUniqueKey) {
    registerPlugin(PersistPlugin(key: globallyUniqueKey));
  }
}
