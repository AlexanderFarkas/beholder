import 'package:meta/meta.dart';
import 'core.dart';
import 'typedefs.dart';

abstract mixin class ViewModel implements Disposable {
  @protected
  final disposers = <Disposer>{};

  @protected
  ObservableState<T> state<T>(
    T value, {
    Equals<T>? equals,
  }) =>
      disposable(RootObservableState<T>(value, equals: equals));

  @protected
  ObservableComputed<T> computed<T>(
    T Function(Watch watch) compute, {
    Equals<T>? equals,
  }) =>
      disposable(ObservableComputed(compute, equals: equals));

  ComputedFactory<T, TParam> computedFactory<T, TParam>(
    T Function(Watch watch, TParam param) compute,
  ) =>
      disposable(ComputedFactory(compute));

  @protected
  WritableObservableComputed<T> writableComputed<T>({
    required T Function(Watch watch) get,
    required void Function(T value) set,
    Equals<T>? equals,
  }) =>
      disposable(WritableObservableComputed(
        get: get,
        set: set,
        equals: equals,
      ));

  T disposable<T extends Disposable>(T disposable) {
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
