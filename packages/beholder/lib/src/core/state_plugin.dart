part of core;

abstract class StatePlugin<T> {
  late final RootObservableState<T> state;

  @nonVirtual
  void attach(RootObservableState<T> state) {
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
