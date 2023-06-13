part of '../core.dart';

class ObservableValue<T> extends Observable<T> {
  ObservableValue(T value, {Equals<T>? equals})
      : _value = value,
        equals = equals ?? Observable.defaultEquals;

  final Equals<T> equals;
  T _value;

  @override
  T get value => _value;
  set value(T value) {
    final oldValue = _value;
    _value = value;
    if (!equals(oldValue, _value)) {
      _markObserversNeedUpdate();
      _notifyObservers();
    }
  }

  T update(T Function(T previous) updater) {
    value = updater(value);
    return value;
  }

  void _markObserversNeedUpdate() {
    for (final observer in _observers) {
      observer.markNeedsUpdate();
    }
  }

  void _notifyObservers() {
    assert(() {
      log("Observable($this) notifies observers");
      return true;
    }());
    final childQueue = Queue<Observer>();

    childQueue.addAll(_observers);

    while (childQueue.isNotEmpty) {
      final observer = childQueue.removeFirst();
      observer.update();
      if (observer case Observable(_observers: var observers)) {
        childQueue.addAll(observers);
      }
    }
  }
}
