part of core;

abstract class StatePlugin<T> {
  void onMounted(RootObservable<T> observable) {}
  void onUnmounted(RootObservable<T> observable) {}
  void onValueChanged(T value) {}
  void onObserverAdded(ObserverMixin observer) {}
  void onObserverRemoved(ObserverMixin observer) {}
}
