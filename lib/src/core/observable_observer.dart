part of '../core.dart';

abstract class ObservableObserver<T>
    with ObserverMixin, ProxyObservableMixin<T>, DebugReprMixin
    implements Observable<T> {
  ObservableObserver() {
    final stateDelegate = createStateDelegate();
    assert(stateDelegate.delegatedByObserver == null);
    stateDelegate.delegatedByObserver = this;
    this.inner = stateDelegate;
  }

  @protected
  ObservableState<T> createStateDelegate();

  @override
  @protected
  late final ObservableState<T> inner;

  @override
  T get value {
    ObservableScope().updateObserver(this);
    return inner.value;
  }

  @override
  @mustCallSuper
  void dispose() {
    inner.dispose();
    stopObserving();
  }
}
