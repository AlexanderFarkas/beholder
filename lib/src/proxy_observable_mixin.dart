import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:warden/src/typedefs.dart';

import 'core.dart';

mixin ProxyObservableMixin<T> implements Observable<T> {
  @visibleForTesting
  abstract final WritableObservable<T> inner;

  @override
  void addObserver(ObserverMixin observer) => inner.addObserver(observer);

  @override
  Stream<T> asStream() => inner.asStream();

  @override
  Dispose listen(ValueChanged<T> onChanged) => inner.listen(onChanged);

  @override
  UnmodifiableSetView<ObserverMixin> get observers => inner.observers;

  @override
  void removeObserver(ObserverMixin observer) => inner.removeObserver(observer);

  @override
  T get value => inner.value;
}
