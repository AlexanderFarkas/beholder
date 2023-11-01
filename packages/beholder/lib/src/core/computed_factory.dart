part of core;

class ComputedFactory<TValue, TParam> implements Disposable {
  ComputedFactory(this._compute);

  final TValue Function(Watch watch, TParam) _compute;

  @visibleForTesting
  final Map<TParam, ObservableComputed<TValue>> cache = {};

  ObservableComputed<TValue> call(TParam param) {
    if (cache[param] case final cached?) {
      return cached;
    }

    final computed = ObservableComputed<TValue>((watch) => _compute(watch, param));

    computed.addPlugin(StatePlugin.inline(
      onObserverRemoved: (_) {
        if (_isDisposed) return;
        if (computed.observers.isEmpty) {
          cache.remove(param);
          Future.microtask(() => computed.dispose());
        }
      },
      onDisposed: () {
        if (_isDisposed) return;
        cache.remove(param);
      },
    ));
    cache[param] = computed;

    Future.microtask(() {
      if (_isDisposed) return;
      if (!computed.isDisposed && computed.observers.isEmpty) {
        cache.remove(param);
        computed.dispose();
      }
    });

    return computed;
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    for (final computed in cache.values) {
      computed.dispose();
    }
  }
}

typedef CleanUp = void Function();
