part of core;

abstract class StatePlugin<T> {
  StatePlugin();
  factory StatePlugin.inline({
    void Function()? onAttached,
    void Function()? onDisposed,
    void Function(T value)? onValueRejected,
    void Function(T previous, T current)? onValueChanged,
    void Function(ObserverMixin observer)? onObserverAdded,
    void Function(ObserverMixin observer)? onObserverRemoved,
  }) = _InlinePlugin<T>;

  late final BaseObservableState<T> state;

  @nonVirtual
  void attach(BaseObservableState<T> state) {
    this.state = state;
    onAttached();
  }

  void onAttached() {}

  void onDisposed() {}

  void onValueRejected(T value) {}

  void onValueChanged(T previous, T current) {}

  void onObserverAdded(ObserverMixin observer) {}

  void onObserverRemoved(ObserverMixin observer) {}
}

class _InlinePlugin<T> extends StatePlugin<T> {
  final void Function()? _onAttached;
  final void Function()? _onDisposed;
  final void Function(T value)? _onValueRejected;
  final void Function(T previous, T current)? _onValueChanged;
  final void Function(ObserverMixin observer)? _onObserverAdded;
  final void Function(ObserverMixin observer)? _onObserverRemoved;

  _InlinePlugin(
      {void Function()? onAttached,
      void Function()? onDisposed,
      void Function(T value)? onValueRejected,
      void Function(T previous, T current)? onValueChanged,
      void Function(ObserverMixin observer)? onObserverAdded,
      void Function(ObserverMixin observer)? onObserverRemoved})
      : _onAttached = onAttached,
        _onDisposed = onDisposed,
        _onValueRejected = onValueRejected,
        _onValueChanged = onValueChanged,
        _onObserverAdded = onObserverAdded,
        _onObserverRemoved = onObserverRemoved;

  @override
  void onAttached() => _onAttached?.call();

  @override
  void onDisposed() => _onDisposed?.call();

  @override
  void onValueRejected(T value) => _onValueRejected?.call(value);

  @override
  void onValueChanged(T previous, T current) => _onValueChanged?.call(previous, current);

  @override
  void onObserverAdded(ObserverMixin observer) => _onObserverAdded?.call(observer);

  @override
  void onObserverRemoved(ObserverMixin observer) => _onObserverRemoved?.call(observer);
}
