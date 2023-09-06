part of '../core.dart';

abstract interface class Disposable {
  void dispose();
}

abstract interface class Observable<T> implements Disposable {
  static bool debugEnabled = false;
  static bool Function(Object? previous, Object? next) defaultEquals =
      (previous, next) => previous == next;

  T get value;
  Stream<T> asStream();
  Dispose listen(ValueChanged<T> onChanged);
  void addObserver(ObserverMixin observer);
  void removeObserver(ObserverMixin observer);
  UnmodifiableSetView<ObserverMixin> get observers;
}

abstract interface class WritableObservable<T> implements Observable<T> {
  set value(T value);
}

mixin WritableObservableMixin<T> implements WritableObservable<T> {
  bool setValue(T value);
  void update(T Function(T current) updater) {
    value = updater(this.value);
  }

  @override
  set value(T value) => setValue(value);
}
