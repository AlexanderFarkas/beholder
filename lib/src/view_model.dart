import 'package:meta/meta.dart';
import 'computed.dart';
import 'future.dart';
import 'typedefs.dart';
import 'core.dart';

class ViewModel {
  @protected
  final disposers = <Dispose>{};

  @protected
  ObservableState<T> state<T>(
    T value, {
    Equals<T>? equals,
    ValueChanged<T>? onSet,
  }) {
    final state = ObservableState<T>(
      value,
      equals: equals,
      onSet: onSet,
    );
    disposers.add(state.dispose);
    return state;
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
    final writableComputed = ObservableWritableComputed(
      get: get,
      set: set,
      equals: equals,
    );
    disposers.add(writableComputed.dispose);
    return writableComputed;
  }

  @protected
  ObservableAsyncState<T> asyncState<T>({
    AsyncValue<T>? value,
    Duration? debounceTime,
    Duration? throttleTime,
    Equals<T>? equals,
  }) {
    final asyncState = ObservableAsyncState<T>(
      value: value,
      debounceTime: debounceTime,
      throttleTime: throttleTime,
      equals: equals,
    );
    disposers.add(asyncState.dispose);
    return asyncState;
  }

  @mustCallSuper
  void dispose() {
    for (final disposer in disposers) {
      disposer();
    }
  }
}
