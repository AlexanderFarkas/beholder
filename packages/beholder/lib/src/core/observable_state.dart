part of core;

typedef ValueChanged<T> = void Function(T value);
typedef ValueSetter<T> = T Function(T value);

class ObservableState<T>
    with DebugReprMixin, WritableObservableMixin<T>
    implements RootObservable<T> {
  ObservableState(
    T value, {
    Equals<T>? equals,
    ValueChanged<T>? onSet,
  })  : _value = value,
        _equals = equals ?? Observable.defaultEquals {
    if (onSet != null) {
      _eagerListeners.add(onSet);
    }
  }

  @override
  T get value => _value;

  @override
  bool setValue(T value) {
    final oldValue = _value;
    _value = value;
    final willUpdate = !_equals(oldValue, value);
    if (willUpdate) {
      ObservableScope().invalidateState(this);
      for (final listener in _eagerListeners) {
        listener(value);
      }

      for (final plugin in _plugins) {
        plugin.onValueChanged(value);
      }
    }

    return willUpdate;
  }

  @override
  Dispose listen(ValueChanged<T> onChanged, {bool eager = false}) {
    assert(!_debugDisposed, "$this is already disposed");

    if (eager) {
      final isNew = _eagerListeners.add(onChanged);
      assert(isNew, "Listener already added");
      return () => _eagerListeners.remove(onChanged);
    } else {
      final observer = ListenObserver(() => onChanged(value));
      addObserver(observer);
      return () => removeObserver(observer);
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
    for (final plugin in _plugins) {
      plugin.onUnmounted(this);
    }
    _plugins.clear();
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
    observer.onAddedToState(this);
    _observers.add(observer);

    for (final plugin in _plugins) {
      plugin.onObserverAdded(observer);
    }
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

    for (final plugin in _plugins) {
      plugin.onObserverRemoved(observer);
    }
  }

  @override
  late final observers = UnmodifiableSetView(_observers);

  final _observers = <ObserverMixin>{};
  late final Lazy<StreamController<T>> _controller = Lazy(
    () {
      Dispose? disposeListen;
      late StreamController<T> controller;
      controller = StreamController<T>.broadcast(
        sync: true,
        onCancel: () => disposeListen?.call(),
        onListen: () => disposeListen = listen((value) => controller.add(value)),
      );
      return controller;
    },
    dispose: (controller) => controller.close(),
  );

  bool _debugDisposed = false;

  final _plugins = <StatePlugin<T>>[];

  @override
  void registerPlugin(StatePlugin<T> plugin) {
    _plugins.add(plugin);
    plugin.onMounted(this);
  }

  @override
  void unregisterPlugin(StatePlugin<T> plugin) {
    _plugins.remove(plugin);
    plugin.onUnmounted(this);
  }
}
