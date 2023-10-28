part of core;

/// Every [ObservableObserver] has an inner [RootObservableState].
/// The inner state is used to track the dependencies of the observer.
///
/// Observers are notified when the inner state changes.
abstract class ObservableObserver<T>
    with ObserverMixin, ObservableProxyMixin<T>, DebugReprMixin
    implements Observable<T> {
  @protected
  RootObservableState<T> createStateDelegate();

  @override
  @protected
  RootObservableState<T> get inner {
    _inner ??= _createInner();
    return _inner!;
  }

  RootObservableState<T> _createInner() {
    final stateDelegate = createStateDelegate();
    assert(stateDelegate.delegatedByObserver == null);
    stateDelegate.delegatedByObserver = this;
    return stateDelegate;
  }

  RootObservableState<T>? _inner;

  @override
  T get value {
    ObservableContext().updateObserver(this);
    return inner.value;
  }

  bool get isDisposed => inner.isDisposed;

  @override
  @mustCallSuper
  void dispose() {
    inner.dispose();
    stopObserving();
  }
}
