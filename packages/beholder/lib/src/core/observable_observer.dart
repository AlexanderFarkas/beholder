part of core;

/// Every [ObservableObserver] has an inner [RootObservableState].
/// The inner state is used to track the dependencies of the observer.
///
/// Observers are notified when the inner state changes.
abstract class ObservableObserver<T>
    with ObserverMixin, ObservableProxyMixin<T>, DebugReprMixin
    implements Observable<T> {
  ObservableObserver() {
    final stateDelegate = createStateDelegate();
    assert(stateDelegate.delegatedByObserver == null);
    stateDelegate.delegatedByObserver = this;
    this.inner = stateDelegate;
  }

  @protected
  RootObservableState<T> createStateDelegate();

  @override
  @protected
  late final RootObservableState<T> inner;

  @override
  T get value {
    ObservableContext().updateObserver(this);
    return inner.value;
  }

  @override
  @mustCallSuper
  void dispose() {
    inner.dispose();
    stopObserving();
  }
}
