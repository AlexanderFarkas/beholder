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
        if (computed.observers.isEmpty) {
          cache.remove(param);
          Future.microtask(() => computed.dispose());
        }
      },
      onDisposed: () {
        cache.remove(param);
      },
    ));
    cache[param] = computed;

    Future.microtask(() {
      if (!computed.isDisposed && computed.observers.isEmpty) {
        cache.remove(param);
        computed.dispose();
      }
    });

    return computed;
  }

  @override
  void dispose() {
    for (final computed in cache.values) {
      computed.dispose();
    }
  }
}

typedef CleanUp = void Function();
