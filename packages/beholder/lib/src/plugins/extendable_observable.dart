part of plugins;

abstract interface class Extendable<T> {
  void addPlugin(StatePlugin<T> plugin);
}
