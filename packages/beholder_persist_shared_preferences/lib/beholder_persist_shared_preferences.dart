library beholder_persist_shared_preferences;

import 'package:beholder_persist/beholder_persist.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStorage extends PersistentStorage<String> {
  final SharedPreferences _preferences;

  SharedPreferencesStorage(this._preferences);

  @override
  TValue? read<TValue>(String key) {
    if (getSerializer<TValue>() case final serializer?) {
      final stored = _preferences.get(key) as String?;
      if (stored == null) return null;
      return serializer.deserialize(stored);
    }

    return _preferences.get(key) as TValue?;
  }

  @override
  void write<TValue>(String key, dynamic value) {
    if (getSerializer<TValue>() case final serializer?) {
      _preferences.setString(key, serializer.serialize(value));
      return;
    }

    switch (value) {
      case int():
        _preferences.setInt(key, value);
      case double():
        _preferences.setDouble(key, value);
      case String():
        _preferences.setString(key, value);
      case bool():
        _preferences.setBool(key, value);
      case List<String>():
        _preferences.setStringList(key, value);
      default:
        throw Exception("Unsupported type: ${value.runtimeType}");
    }
  }
}
