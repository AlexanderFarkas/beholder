part of '../core.dart';

abstract class Observable<T> with Diagnosticable {
  static bool debugEnabled = false;
  static bool defaultEquals(Object? previous, Object? next) {
    return previous == next;
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

  T get value;
  Stream<T> asStream() => _controller.get().stream;
  bool _debugDisposed = false;

  void addObserver(Observer observer) {
    assert(!_debugDisposed, "Observable[$this] is already disposed");
    assert(() {
      if (!_observers.contains(observer)) {
        log("Observer[$observer] added to observable[$this]");
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

  Dispose listen(void Function(T value) onChanged) {
    final observer = InlineObserver(() => onChanged(value));
    addObserver(observer);
    return () => removeObserver(observer);
  }

  @mustCallSuper
  dispose() {
    assert(() {
      _debugDisposed = true;
      log("Observable[$this] disposed");
      return true;
    }());
    _controller.dispose();
    _observers.clear();
  }
}
