part of '../core.dart';

class ObservableComputed<T> extends Observable<T> with Observer {
  final T Function(Observe observe) compute;
  late final Observatory observatory;
  ObservableComputed(this.compute, {Equals<T>? equals})
      : equals = equals ?? Observable.defaultEquals {
    observatory = Observatory(this);
    _value = observatory.proxy(compute);
  }

  final Equals<T> equals;
  late T _value;

  @override
  T get value => _value;

  @override
  void performUpdate() {
    final oldValue = _value;
    _value = observatory.proxy(compute);

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
