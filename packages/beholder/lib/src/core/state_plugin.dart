part of core;

abstract class StatePlugin<T> {
  late final ObservableState<T> state;

  @nonVirtual
  void attach(ObservableState<T> state) {
    this.state = state;
    onAttached();
  }

  void onAttached() {}
  void onDisposed() {}
  void onValueChanged(T previous, T value) {}
  void onObserverAdded(ObserverMixin observer) {}
  void onObserverRemoved(ObserverMixin observer) {}
}
