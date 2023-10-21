part of core;

/// Every [ObservableObserver] has an inner [ObservableState].
/// The inner state is used to track the dependencies of the observer.
///
/// Observers are notified when the inner state changes.
abstract class ObservableObserver<T>
    with ObserverMixin, ProxyObservableStateMixin<T>, DebugReprMixin
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
