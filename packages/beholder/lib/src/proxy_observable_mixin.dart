import 'dart:collection';

import 'package:meta/meta.dart';

import 'core.dart';
import 'typedefs.dart';

mixin ProxyObservableStateMixin<T> implements Observable<T> {
  @visibleForTesting
  abstract final ObservableState<T> inner;

  @override
  void addObserver(ObserverMixin observer) => inner.addObserver(observer);

  @override
  Stream<T> asStream() => inner.asStream();

  @override
  Disposer listen(ValueChanged<T> onChanged) => inner.listen(onChanged);

  @override
  UnmodifiableSetView<ObserverMixin> get observers => inner.observers;

  @override
  void removeObserver(ObserverMixin observer) => inner.removeObserver(observer);

  @override
  T get value => inner.value;
}
