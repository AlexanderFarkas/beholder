part of '../core.dart';

abstract class Observable<T> {
  static bool debugEnabled = false;
  static bool Function(Object? previous, Object? next) defaultEquals =
      (previous, next) => previous == next;

  T get value;

  Stream<T> asStream() => _controller.get().stream;

  Dispose listen(void Function(T value) onChanged) {
    assert(!debugDisposed, "$this is already disposed");
    final observer = InlineObserver(() => onChanged(value));
    addObserver(observer);
    return () => removeObserver(observer);
  }

  void addObserver(Observer observer) {
    assert(!debugDisposed, "$this is already disposed");
    assert(() {
      if (!_observers.contains(observer)) {
        log("$observer added to $this");
      }
      return true;
    }());
    _observers.add(observer);
  }

  void removeObserver(Observer observer) {
    assert(() {
      if (_observers.contains(observer)) {
        log("Observer[$observer] removed from [$this]");
      }
      return true;
    }());
    _observers.remove(observer);
  }

  @mustCallSuper
  void dispose() {
    assert(() {
      _debugDisposed = true;
      log("Observable[$this] disposed");
      return true;
    }());
    _controller.dispose();
    _observers.clear();
  }

  static bool _defaultEquals(Object? previous, Object? next) {
    return Observable.defaultEquals(previous, next);
  }

  final _observers = <Observer>{};
  late final Lazy<StreamController<T>> _controller = Lazy(
    () {
      final controller = StreamController<T>.broadcast();
      listen((value) => controller.add(value));
      return controller;
    },
    dispose: (controller) => controller.close(),
  );

  bool _debugDisposed = false;

  @protected
  get debugDisposed => _debugDisposed;

  @override
  String toString() {
    return "$runtimeType${shortHash(this)}($value)";
  }
}

/// Returns a 5 character long hexadecimal string generated from
/// [Object.hashCode]'s 20 least-significant bits.
String shortHash(Object? object) {
  return "#${object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0')}";
}
