part of '../core.dart';

class ObservableComputed<T> extends Observable<T> {
  final T Function(Observe watch) compute;
  late final Observatory observatory;
  ObservableComputed(this.compute, {Equals<T>? equals})
      : equals = equals ?? Observable.defaultEquals {
    _value = compute(observatory.observe);
  }

  final Equals<T> equals;
  late T _value;

  @override
  T get value => _value;

  @override
  void performUpdate() {
    final oldValue = _value;
    _value = compute(observatory.observe);

    if (!equals(oldValue, _value)) {
      for (final observer in _observers) {
        observer.markNeedsUpdate();
      }
    }
  }

  @override
  dispose() {
    observatory.dispose();
    super.dispose();
  }
}
