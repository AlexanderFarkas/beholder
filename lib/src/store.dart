part of 'core.dart';

class Store {
  @protected
  final onDispose = <Dispose>{};

  @protected
  ObservableValue<T> observable<T>(T value, {Equals<T>? equals}) {
    final observable = ObservableValue<T>(value, equals: equals);
    onDispose.add(observable.dispose);
    return observable;
  }

  @protected
  ObservableComputed<T> computed<T>(
    T Function(Observe watch) compute, {
    Equals<T>? equals,
  }) {
    final computed = ObservableComputed(compute, equals: equals);
    onDispose.add(computed.dispose);
    return computed;
  }

  @mustCallSuper
  void dispose() {
    for (final disposer in onDispose) {
      disposer();
    }
  }
}
