part of future;

class ObservableAsyncState<T>
    with WritableObservableMixin<AsyncValue<T>>
    implements WritableObservable<AsyncValue<T>> {
  ObservableAsyncState({
    AsyncValue<T>? value,
    Duration? debounceTime,
    Duration? throttleTime,
    Equals<T>? equals,
    ValueChanged<AsyncValue<T>>? onSet,
  })  : _debounceTime = debounceTime ?? const Duration(milliseconds: 0),
        _throttleTime = throttleTime ?? const Duration(milliseconds: 0),
        _equals = equals ?? Observable.defaultEquals {
    _value = ObservableState<AsyncValue<T>>(
      value ?? const Loading(),
      equals: (a1, a2) => a1._equals(a2, equals: _equals),
      onSet: onSet,
    );
  }

  late final ObservableState<AsyncValue<T>> _value;

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

    _value.value = Loading.fromPrevious(_value.value);

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
    _value.value = Loading.fromPrevious(_value.value);
    return _process(computation);
  }

  @override
  bool setValue(AsyncValue<T> value) {
    _cancelThrottle();
    _cancelDebounce();
    _currentFuture = null;
    return _value.setValue(value);
  }

  @override
  AsyncValue<T> get value => _value.value;

  @override
  void addObserver(ObserverMixin observer) => _value.addObserver(observer);

  @override
  Stream<AsyncValue<T>> asStream() => _value.asStream();

  @override
  Dispose listen(ValueChanged<AsyncValue<T>> onChanged) => _value.listen(onChanged);

  @override
  UnmodifiableSetView<ObserverMixin> get observers => _value.observers;

  @override
  void removeObserver(ObserverMixin observer) => _value.observers;

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
      _value.value = value;
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
    _value.dispose();
    _cancelDebounce();
    _cancelThrottle();
  }

  final Duration _debounceTime;
  final Duration _throttleTime;

  Future? _currentFuture;
  Timer? _debounceTimer;
  Timer? _throttleTimer;
  Equals<T> _equals;
}
