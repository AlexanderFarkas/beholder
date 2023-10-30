part of core;

/// Every [ObservableComputed] has an inner [BaseObservableState].
/// The inner state is used to track the dependencies of the observer.
///
/// Observers are notified when the inner state changes.
class ObservableComputed<T>
    with ObserverMixin, ObservableProxyMixin<T>, DebugReprMixin
    implements Observable<T>, Extendable<T> {
  ObservableComputed(this._compute, {this.equals});
  final T Function(Watch watch) _compute;
  final Equals<T>? equals;

  @override
  @protected
  BaseObservableState<T> get inner {
    if (_inner == null) {
      final state = ComputedState(
        trackObservables(_compute),
        equals: equals,
        delegatedBy: this,
      );

      ObservableContext().trackComputedCreated(this);
      _inner = state;
    }

    return _inner!;
  }

  ComputedState<T>? _inner;

  @override
  @visibleForOverriding
  Rebuild prepare() {
    final value = trackObservables(_compute);
    return () => inner.setValue(value);
  }

  @override
  T get value {
    ObservableContext().updateComputed(this);
    return inner.value;
  }

  bool get isDisposed => inner.isDisposed;

  @override
  void addPlugin(StatePlugin<T> plugin) {
    inner.addPlugin(plugin);
  }

  @override
  @mustCallSuper
  void dispose() {
    inner.dispose();
    stopObserving();
  }
}

final class ComputedState<T> extends BaseObservableState<T> {
  ComputedState(
    super.value, {
    required this.delegatedBy,
    super.equals,
  });

  @override
  void onValueSet(T from, T to) {}

  final ObservableComputed delegatedBy;

  @override
  Disposer listenSync(ValueChanged<T> onChanged) {
    assert(
      false,
      "There is no practical sense in sync listening to ObservableObserverState - it's modified asynchronously.",
    );
    return super.listenSync(onChanged);
  }
}
