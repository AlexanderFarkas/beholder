part of '../core.dart';

abstract interface class ObservableObserver<T> implements Observable<T>, ObserverMixin {}

abstract class DelegatedObservableObserver<T>
    with ObserverMixin, DebugReprMixin
    implements ObservableObserver<T> {
  DelegatedObservableObserver() {
    final stateDelegate = createStateDelegate();
    assert(stateDelegate.delegatedByObserver == null);
    stateDelegate.delegatedByObserver = this;
    this.stateDelegate = stateDelegate;
  }

  @protected
  ObservableState<T> createStateDelegate();

  @protected
  late final ObservableState<T> stateDelegate;

  @override
  void addObserver(ObserverMixin observer) => stateDelegate.addObserver(observer);

  @override
  Stream<T> asStream() => stateDelegate.asStream();

  @override
  Dispose listen(ValueChanged<T> onChanged) => stateDelegate.listen(onChanged);

  @override
  UnmodifiableSetView<ObserverMixin> get observers => stateDelegate.observers;

  @override
  void removeObserver(ObserverMixin observer) => stateDelegate.removeObserver(observer);

  @override
  T get value => stateDelegate.value;

  @override
  @mustCallSuper
  void dispose() {
    stateDelegate.dispose();
    stopObserving();
  }
}
