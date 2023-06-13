part of 'core.dart';

log(String message) {
  if (Observable.debugEnabled) {
    developer.log(message);
  }
}

class Lazy<T> {
  final T Function() builder;
  final void Function(T)? _dispose;

  Lazy(this.builder, {void Function(T)? dispose}) : _dispose = dispose;

  late T _value;
  bool isInitialized = false;
  T get() {
    if (!isInitialized) {
      _value = builder();
      isInitialized = true;
    }
    return _value;
  }

  void dispose() {
    if (_dispose case var dispose? when isInitialized) {
      dispose(_value);
    }
  }
}
