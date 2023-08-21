part of 'core.dart';

class ViewModel {
  @protected
  final disposers = <Dispose>{};

  @protected
  ObservableValue<T> observable<T>(T value, {Equals<T>? equals}) {
    final observable = ObservableValue<T>(value, equals: equals);
    disposers.add(observable.dispose);
    return observable;
  }

  @protected
  ObservableComputed<T> computed<T>(
    T Function(Observe watch) compute, {
    Equals<T>? equals,
  }) {
    final computed = ObservableComputed(compute, equals: equals);
    disposers.add(computed.dispose);
    return computed;
  }

  ObservableFuture<T> future<T>(
    Future<T> Function(Observe watch) compute, {
    bool? keepPrevious,
    AsyncValue<T>? initial,
    Duration? debounceTime,
    Duration? throttleTime,
    Equals<T>? equals,
  }) {
    final future = ObservableFuture<T>._(
      compute,
      keepPrevious: keepPrevious,
      initial: initial,
      debounceTime: debounceTime,
      throttleTime: throttleTime,
      equals: equals,
    );

    disposers.add(future.dispose);
    return future;
  }

  @mustCallSuper
  void dispose() {
    for (final disposer in disposers) {
      disposer();
    }
  }
}
