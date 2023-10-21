part of plugins;

typedef DisposeValue<T> = void Function(T value);

class AutoDisposePlugin<T> extends StatePlugin<T> {
  final DisposeValue<T> dispose;

  AutoDisposePlugin(this.dispose);

  @override
  void onDisposed() {
    dispose(state.value);
  }

  @override
  void onValueChanged(T previous, T value) {
    dispose(previous);
  }
}

extension AsyncValueAutoDisposePluginX<T extends Disposable?>
    on Extendable<AsyncValue<T>> {
  void autoDispose([DisposeValue<AsyncValue<T>>? disposer]) {
    addPlugin(AutoDisposePlugin(disposer ??
        (value) {
          if (value is Data<T>) {
            value.value?.dispose();
          }
        }));
  }
}

extension DisposableAutoDisposePlugin<T extends Disposable?> on Extendable<T> {
  void autoDispose([DisposeValue<T>? disposer]) {
    addPlugin(AutoDisposePlugin(disposer ?? (value) => value?.dispose()));
  }
}

extension AutoDisposePluginX<T> on Extendable<T> {
  void autoDispose(DisposeValue<T> disposer) {
    addPlugin(AutoDisposePlugin(disposer));
  }
}
