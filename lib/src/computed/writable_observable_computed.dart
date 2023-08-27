part of '../computed.dart';

class ObservableWritableComputed<T> extends ObservableComputed<T> implements WritableObservable<T> {
  ObservableWritableComputed(
      {required T Function(Watch watch) get, required void Function(T value) set, super.equals})
      : _set = set,
        super(get);

  @override
  set value(T value) => _set(value);

  final void Function(T value) _set;
}
