part of future;

class ObservableAsyncState<T>
    with ProxyObservableStateMixin<AsyncValue<T>>, WritableObservableMixin<AsyncValue<T>> {
  ObservableAsyncState({
    AsyncValue<T>? value,
    Duration? debounceTime,
    Duration? throttleTime,
    Equals<T>? equals,
  })  : _debounceTime = debounceTime ?? const Duration(milliseconds: 0),
        _throttleTime = throttleTime ?? const Duration(milliseconds: 0) {
    inner = ObservableState<AsyncValue<T>>(
      value ?? const Loading(),
      equals: (a1, a2) => a1._equals(a2, equals: equals ?? Observable.defaultEquals),
    );
  }

  @override
  late final ObservableState<AsyncValue<T>> inner;

  void scheduleRefresh(Future<T> Function() computation) async {
    final throttleTimer = _throttleTimer;
    if (throttleTimer != null && throttleTimer.isActive) {
      return;
    } else if (_throttleTime != Duration.zero) {
      _cancelThrottle();
      _throttleTimer = Timer(
        _throttleTime,
        () => _throttleTimer = null,
      );
    }

    inner.value = Loading.fromPrevious(inner.value);

    if (_debounceTime != Duration.zero) {
      _cancelDebounce();
      _debounceTimer = Timer(_debounceTime, () {
        _debounceTimer = null;
        _process(computation);
      });
    } else {
      _process(computation);
    }
  }

  Future<AsyncValue<T>> refresh(Future<T> Function() computation) {
    _cancelThrottle();
    _cancelDebounce();
    inner.value = Loading.fromPrevious(inner.value);
    return _process(computation);
  }

  @override
  bool setValue(AsyncValue<T> value) {
    _cancelThrottle();
    _cancelDebounce();
    _currentFuture = null;
    return inner.setValue(value);
  }

  Future<AsyncValue<T>> _process(Future<T> Function() execute) async {
    Future<T>? future;
    try {
      future = execute();
    } catch (e, s) {
      future ??= Future.error(e, s);
    }
    _currentFuture = future;
    final value = await Result.guard(() => future!);
    if (_currentFuture == future) {
      inner.value = value;
    }
    return value;
  }

  void _cancelThrottle() {
    _throttleTimer?.cancel();
    _throttleTimer = null;
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  @override
  void dispose() {
    inner.dispose();
    _cancelDebounce();
    _cancelThrottle();
  }

  final Duration _debounceTime;
  final Duration _throttleTime;

  Future? _currentFuture;
  Timer? _debounceTimer;
  Timer? _throttleTimer;
}
