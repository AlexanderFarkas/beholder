part of future;

class ObservableFuture<T> extends DelegatedObservableObserver<AsyncValue<T>>
    implements WritableObservable<AsyncValue<T>> {
  ObservableFuture(
    this._compute, {
    AsyncValue<T>? initial,
    Duration? debounceTime,
    Duration? throttleTime,
    Equals<T>? equals,
  })  : _initial = initial,
        _equals = equals,
        _debounceTime = debounceTime ?? Duration.zero,
        _throttleTime = throttleTime ?? Duration.zero,
        assert(debounceTime == null || throttleTime == null) {
    _executeFuture();
  }

  Future<void> refresh() {
    _cancelThrottle();
    _cancelDebounce();
    _setLoading();
    return _executeFuture();
  }

  @override
  set value(AsyncValue<T> value) {
    _cancelThrottle();
    _cancelDebounce();
    stateDelegate.value = value;
  }

  @override
  void dispose() {
    _cancelThrottle();
    _cancelDebounce();
    super.dispose();
  }

  @override
  @protected
  bool performUpdate() {
    final throttleTimer = _throttleTimer;
    if (throttleTimer != null && throttleTimer.isActive) {
      return false;
    } else if (_throttleTime != Duration.zero) {
      _cancelThrottle();
      _throttleTimer = Timer(
        _throttleTime,
        () => _throttleTimer = null,
      );
    }

    final isUpdated = _setLoading();

    if (_debounceTime != Duration.zero) {
      _cancelDebounce();
      _debounceTimer = Timer(_debounceTime, () {
        _debounceTimer = null;
        _executeFuture();
      });
    } else {
      _executeFuture();
    }

    return isUpdated;
  }

  Future<void> _executeFuture() async {
    final future = _compute(observe);
    _current = future;
    final value = await Result.guard(() => future);
    if (_current == future) {
      stateDelegate.value = value;
    }
  }

  bool _setLoading() {
    return stateDelegate.setValue(
      Loading(
        previousResult: switch (stateDelegate.value) {
          Result() && var result => result,
          Loading(previousResult: var result) => result,
        },
      ),
    );
  }

  @override
  ObservableState<AsyncValue<T>> createStateDelegate() => ObservableState(
        _initial ?? const Loading(),
        equals: (previous, next) =>
            previous._equals(next, equals: _equals ?? Observable.defaultEquals),
      );

  void _cancelThrottle() {
    _throttleTimer?.cancel();
    _throttleTimer = null;
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  final Future<T> Function(Watch watch) _compute;
  final Duration _debounceTime;
  final Duration _throttleTime;
  final AsyncValue<T>? _initial;
  final Equals<T>? _equals;
  Timer? _debounceTimer;
  Timer? _throttleTimer;
  Future<T>? _current;
}