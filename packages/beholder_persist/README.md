
An extension to [`beholder`](https://pub.dev/packages/beholder_flutter) package, which allows to persist state of `beholder`'s `state` and `asyncState` objects.

## Getting started
Add one of officially supported storages, or [implement your own](#custom-types).
- [beholder_persist_shared_preferences](https://pub.dev/packages/beholder_persist_shared_preferences)

## Usage
```dart
import 'package:beholder/beholder.dart';
import 'package:beholder_persist/beholder_persist.dart';
import 'package:beholder_persist_shared_preferences/beholder_persist_shared_preferences.dart';

void main() {
    // Uncomment, if you are using Flutter
    // WidgetsFlutterBinding.ensureInitialized(); 
    
    // Create Storage of your choice (here officially supported storage is used)
    final storage = SharedPreferencesStorage();
    PersistPlugin.storage = storage;
    
    // ...
}

class CounterViewModel extends ViewModel {
    late final counter = state(0)
      ..persist('counter');
    
    increment() => counter.value++;
}
```
## Custom Types
If your persistent storage doesn't support custom types, you can use `registerType` to register your own serializer/deserializer:
```dart
class User {
  User(this.name);
  final String name;
  
  Map<String, dynamic> toJson() => {"name": name};
}

void main() {
  final storage = SharedPreferencesStorage()
    ..registerType<User>(
      serializer: (user) => jsonEncode(user.toJson()),
      deserializer: (json) => User.fromJson(jsonDecode(json)),
    );
  PersistPlugin.storage = storage;  
}
```

## Custom storage
To implement your own storage, you need to implement `PersistentStorage` interface:
```dart
class InMemoryStorage extends PersistentStorage {
  final _storage = <String, dynamic>{};
  
  void write(String key, String value) {
    _storage[key] = value;
  }
  
  T? read<T>(String key) {
    return _storage[key] as T?;
  }
}
```

Then, in `main`:
```dart
void main() {
  PersistPlugin.storage = InMemoryStorage();
}
```