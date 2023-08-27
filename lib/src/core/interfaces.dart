part of '../core.dart';

abstract interface class Observable<T> {
  static bool debugEnabled = false;
  static bool Function(Object? previous, Object? next) defaultEquals =
      (previous, next) => previous == next;

  T get value;
  Stream<T> asStream();
  Dispose listen(ValueChanged<T> onChanged);
  void addObserver(ObserverMixin observer);
  void removeObserver(ObserverMixin observer);
  UnmodifiableSetView<ObserverMixin> get observers;
  void dispose();
}

abstract interface class WritableObservable<T> implements Observable<T> {
  set value(T value);
}
