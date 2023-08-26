part of '../core.dart';

class ObservableFuture<T> extends ObservableObserver<AsyncValue<T>>
    implements WritableObservable<AsyncValue<T>> {
  ObservableFuture._(
    this._compute, {
    AsyncValue<T>? initial,
    Duration? debounceTime,
    Duration? throttleTime,
    Equals<T>? equals,
  })  : _value = initial ?? const Loading(),
        _debounceTime = debounceTime ?? Duration.zero,
        _throttleTime = throttleTime ?? Duration.zero,
        _equals = equals ?? Observable.defaultEquals,
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
  AsyncValue<T> get value => _value;

  @override
  set value(AsyncValue<T> value) {
    _cancelThrottle();
    _cancelDebounce();
    _setValue(value);
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
      _setValue(value);
    }
  }

  bool _setLoading() => _setValue(
        Loading(
          previousResult: switch (_value) {
            Result() && var result => result,
            Loading(previousResult: var result) => result,
          },
        ),
      );

  bool _setValue(AsyncValue<T> value) {
    final oldValue = _value;
    _value = value;

    if (!oldValue._equals(_value, equals: _equals)) {
      NotificationScope.markNeedsUpdate(this);
      return true;
    }

    return false;
  }

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
  final Equals<T> _equals;

  AsyncValue<T> _value;
  Timer? _debounceTimer;
  Timer? _throttleTimer;
  Future<T>? _current;
}
