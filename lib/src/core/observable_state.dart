part of '../core.dart';

typedef ValueChanged<T> = void Function(T value);

class ObservableState<T> with DebugReprMixin, WritableObservableMixin<T> {
  ObservableState(T value, {Equals<T>? equals})
      : _value = value,
        _equals = equals ?? Observable.defaultEquals;

  @override
  T get value => _value;

  @override
  bool setValue(T value) {
    final oldValue = _value;
    _value = value;
    final willUpdate = !_equals(oldValue, value);
    if (willUpdate) {
      ObservableScope().invalidate(this);
      for (final listener in _eagerListeners) {
        listener(value);
      }
    }

    return willUpdate;
  }

  @override
  Dispose listen(ValueChanged<T> onChanged, {ScopePhase phase = ScopePhase.notify}) {
    assert(!_debugDisposed, "$this is already disposed");

    if (phase == ScopePhase.notify) {
      final observer = ListenObserver(() => onChanged(value));
      addObserver(observer);
      return () => removeObserver(observer);
    } else {
      final isNew = _eagerListeners.add(onChanged);
      assert(isNew, "Listener already added");
      return () => _eagerListeners.remove(onChanged);
    }
  }

  final Equals<T> _equals;

  T _value;
  final _eagerListeners = <ValueChanged<T>>{};

  @internal
  ObservableObserver? delegatedByObserver;

  @override
  void dispose() {
    assert(() {
      _debugDisposed = true;
      debugLog("$this disposed");
      return true;
    }());
    _eagerListeners.clear();
    _controller.dispose();
    _observers.clear();
  }

  @override
  Stream<T> asStream() => _controller.get().stream;

  @override
  void addObserver(ObserverMixin observer) {
    assert(!_debugDisposed, "$this is already disposed");
    assert(() {
      if (!_observers.contains(observer)) {
        debugLog("$observer starts observing $this");
      }
      return true;
    }());
    observer.observables.add(this);
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
    observer.observables.remove(this);
    _observers.remove(observer);
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
