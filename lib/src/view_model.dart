import 'package:meta/meta.dart';
import 'computed.dart';
import 'future.dart';
import 'typedefs.dart';
import 'core.dart';

class ViewModel {
  @protected
  final disposers = <Dispose>{};

  @protected
  ObservableState<T> state<T>(T value, {Equals<T>? equals}) {
    final observable = ObservableState<T>(value, equals: equals);
    disposers.add(observable.dispose);
    return observable;
  }

  @protected
  ObservableComputed<T> computed<T>(
    T Function(Watch watch) compute, {
    Equals<T>? equals,
  }) {
    final computed = ObservableComputed(compute, equals: equals);
    disposers.add(computed.dispose);
    return computed;
  }

  @protected
  ObservableWritableComputed<T> writableComputed<T>({
    required T Function(Watch watch) get,
    required void Function(T value) set,
    Equals<T>? equals,
  }) {
    final computed = ObservableWritableComputed(
      get: get,
      set: set,
      equals: equals,
    );
    disposers.add(computed.dispose);
    return computed;
  }

  @protected
  ObservableFuture<T> future<T>(
    Future<T> Function() Function(Watch watch) build, {
    AsyncValue<T>? initialValue,
    Duration? debounceTime,
    Duration? throttleTime,
    Equals<T>? equals,
  }) {
    final future = ObservableFuture<T>(
      build,
      initialValue: initialValue,
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
