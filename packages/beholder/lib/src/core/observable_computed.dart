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
    assert(!_isDisposed, "Computed is already disposed");
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
  Failure? _failure;

  @override
  @visibleForOverriding
  Rebuild prepare() {
    try {
      final value = trackObservables(_compute);
      return () {
        _failure = null;
        return inner.setValue(value);
      };
    } catch (e, s) {
      return () {
        _failure = Failure(e, s);
        return false;
      };
    }
  }

  @override
  T get value {
    ObservableContext().updateComputed(this);

    if (_failure case final failure?) {
      Error.throwWithStackTrace(failure.error, failure.stackTrace!);
    }

    return inner.value;
  }

  @override
  void addPlugin(StatePlugin<T> plugin) {
    inner.addPlugin(plugin);
  }

  bool get isDisposed => _isDisposed;

  @override
  @mustCallSuper
  void dispose() {
    _isDisposed = true;
    // if it was never used, don't even create state
    _inner?.dispose();
    stopObserving();
  }

  bool _isDisposed = false;
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
