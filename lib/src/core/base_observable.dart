part of '../core.dart';

abstract class BaseObservable<T> with DebugReprMixin implements Observable<T> {
  @override
  Stream<T> asStream() => _controller.get().stream;

  @override
  Dispose listen(ValueChanged<T> onChanged) {
    assert(!_debugDisposed, "$this is already disposed");
    final observer = ListenObserver(() => onChanged(value));
    addObserver(observer);
    return () => removeObserver(observer);
  }

  @override
  void addObserver(ObserverMixin observer) {
    assert(!_debugDisposed, "$this is already disposed");
    assert(() {
      if (!_observers.contains(observer)) {
        debugLog("$observer starts observing $this");
      }
      return true;
    }());
    _observers.add(observer);
  }

  @override
  void removeObserver(ObserverMixin observer) {
    assert(() {
      if (_observers.contains(observer)) {
        debugLog("$observer stops observing $this");
      }
      return true;
    }());
    _observers.remove(observer);
  }

  @override
  @mustCallSuper
  void dispose() {
    assert(() {
      _debugDisposed = true;
      debugLog("$this disposed");
      return true;
    }());
    _controller.dispose();
    _observers.clear();
  }

  @override
  late final observers = UnmodifiableSetView(_observers);

  final _observers = <ObserverMixin>{};

  late final Lazy<StreamController<T>> _controller = Lazy(
    () {
      final controller = StreamController<T>.broadcast();
      listen((value) => controller.add(value));
      return controller;
    },
    dispose: (controller) => controller.close(),
  );

  bool _debugDisposed = false;
}
