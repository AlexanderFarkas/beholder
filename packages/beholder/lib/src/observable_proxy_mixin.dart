import 'dart:collection';

import 'package:meta/meta.dart';

import 'core.dart';
import 'typedefs.dart';

mixin ObservableProxyMixin<T> implements Observable<T> {
  Observable<T> get inner;

  @override
  T get value => inner.value;

  @override
  Stream<T> asStream() => inner.asStream();

  @override
  Disposer listen(ValueChanged<T> onChanged) => inner.listen(onChanged);

  @override
  UnmodifiableSetView<ObserverMixin> get observers => inner.observers;

  @override
  void addObserver(ObserverMixin observer) => inner.addObserver(observer);

  @override
  void removeObserver(ObserverMixin observer) => inner.removeObserver(observer);
}

mixin ObservableStateProxyMixin<T> implements ObservableState<T> {
  ObservableState<T> get inner;

  @override
  bool setValue(value) => inner.setValue(value);

  @override
  set value(T value) => setValue(value);

  @override
  T get value => inner.value;

  @override
  Stream<T> asStream() => inner.asStream();

  @override
  Disposer listen(ValueChanged<T> onChanged) => inner.listen(onChanged);

  @override
  Disposer listenSync(ValueChanged<T> onChanged) => inner.listenSync(onChanged);

  @override
  void addPlugin(StatePlugin<T> plugin) => inner.addPlugin(plugin);

  @override
  UnmodifiableSetView<ObserverMixin> get observers => inner.observers;

  @override
  void addObserver(ObserverMixin observer) => inner.addObserver(observer);

  @override
  void removeObserver(ObserverMixin observer) => inner.removeObserver(observer);
}
