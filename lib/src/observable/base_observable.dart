part of '../core.dart';

abstract class BaseObservable<T> implements Observable<T> {
  @override
  Stream<T> asStream() => _controller.get().stream;

  @override
  Dispose listen(ValueChanged<T> onChanged) {
    assert(!debugDisposed, "$this is already disposed");
    final observer = InlineObserver(() => onChanged(value));
    addObserver(observer);
    return () => removeObserver(observer);
  }

  @override
  void addObserver(ObserverMixin observer) {
    assert(!debugDisposed, "$this is already disposed");
    assert(() {
      if (!_observers.contains(observer)) {
        log("$observer added to $this");
      }
      return true;
    }());
    _observers.add(observer);
  }

  @override
  void removeObserver(ObserverMixin observer) {
    assert(() {
      if (_observers.contains(observer)) {
        log("$observer removed from [$this]");
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
      log("$this disposed");
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

  @protected
  get debugDisposed => _debugDisposed;

  @override
  String toString() {
    return "$runtimeType${shortHash(this)}";
  }
}

/// Returns a 5 character long hexadecimal string generated from
/// [Object.hashCode]'s 20 least-significant bits.
String shortHash(Object? object) {
  return "#${object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0')}";
}
