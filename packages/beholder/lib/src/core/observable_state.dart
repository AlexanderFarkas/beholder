part of core;

typedef ValueChanged<T> = void Function(T previous, T next);
typedef ValueSetter<T> = T Function(T value);

final class ObservableState<T>
    with DebugReprMixin, WritableObservableMixin<T>
    implements Extendable<T> {
  ObservableState(
    T value, {
    Equals<T>? equals,
  })  : _value = value,
        _equals = equals ?? Observable.defaultEquals;

  @override
  T get value => _value;

  @override
  bool setValue(T value) {
    final oldValue = _value;
    final willUpdate = !_equals(oldValue, value);
    if (willUpdate) {
      _value = value;

      invalidate();
      for (final listener in _eagerListeners) {
        listener(oldValue, value);
      }

      for (final plugin in _plugins) {
        plugin.onValueChanged(oldValue, value);
      }
    }

    return willUpdate;
  }

  void invalidate() {
    ObservableContext().invalidateState(this);
  }

  /// Adds observer, which will be called after.
  @override
  Disposer listen(ValueChanged<T> onChanged) {
    assert(!_debugDisposed, "$this is already disposed");

    final observer = ValueChangedObserver(onChanged);
    addObserver(observer);
    return () => removeObserver(observer);
  }

  /// [onChanged] is called before *any* other observer is notified.
  /// This is useful if you want to update other [ObservableState]s in the same [ObservableContext] phase.
  ///
  /// Use it only if you know what you are doing.
  /// Safer, but less performant, alternative is to use [listen].
  Disposer listenSync(ValueChanged<T> onChanged) {
    assert(!_debugDisposed, "$this is already disposed");

    final isNew = _eagerListeners.add(onChanged);
    assert(isNew, "Listener already added");
    return () => _eagerListeners.remove(onChanged);
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
      plugin.onDisposed();
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
    observer.onRemovedFromState(this);
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
      Disposer? disposeListen;
      late StreamController<T> controller;
      controller = StreamController<T>.broadcast(
        sync: true,
        onCancel: () => disposeListen?.call(),
        onListen: () =>
            disposeListen = listen((_, value) => controller.add(value)),
      );
      return controller;
    },
    dispose: (controller) => controller.close(),
  );

  bool _debugDisposed = false;

  final _plugins = <StatePlugin<T>>[];

  @override
  void addPlugin(StatePlugin<T> plugin) {
    _plugins.add(plugin);
    plugin.attach(this);
  }
}
