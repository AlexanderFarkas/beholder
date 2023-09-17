import 'package:meta/meta.dart';
import 'computed.dart';
import 'core.dart';
import 'future.dart';
import 'typedefs.dart';

abstract mixin class ViewModel implements Disposable {
  @protected
  final disposers = <Dispose>{};

  @protected
  ObservableState<T> state<T>(
    T value, {
    Equals<T>? equals,
    ValueChanged<T>? onSet,
  }) =>
      autoDispose(ObservableState<T>(
        value,
        equals: equals,
        onSet: onSet,
      ));

  @protected
  ObservableComputed<T> computed<T>(
    T Function(Watch watch) compute, {
    Equals<T>? equals,
  }) =>
      autoDispose(ObservableComputed(compute, equals: equals));

  @protected
  WritableObservableComputed<T> writableComputed<T>({
    required T Function(Watch watch) get,
    required void Function(T value) set,
    Equals<T>? equals,
  }) =>
      autoDispose(WritableObservableComputed(
        get: get,
        set: set,
        equals: equals,
      ));

  @protected
  ObservableAsyncState<T> asyncState<T>({
    AsyncValue<T>? value,
    Duration? debounceTime,
    Duration? throttleTime,
    Equals<T>? equals,
  }) =>
      autoDispose(ObservableAsyncState<T>(
        value: value,
        debounceTime: debounceTime,
        throttleTime: throttleTime,
        equals: equals,
      ));

  @protected
  T autoDispose<T extends Disposable>(T disposable) {
    disposers.add(disposable.dispose);
    return disposable;
  }

  @override
  @mustCallSuper
  void dispose() {
    for (final disposer in disposers) {
      disposer();
    }
  }
}
