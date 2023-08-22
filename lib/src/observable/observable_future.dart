part of '../core.dart';

class ObservableFuture<T> extends ObservableObserver<AsyncValue<T>> {
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
      ObservableScope.markNeedsUpdate(this);
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

  final Future<T> Function(Observe observe) _compute;
  final Duration _debounceTime;
  final Duration _throttleTime;
  final Equals<T> _equals;

  AsyncValue<T> _value;
  Timer? _debounceTimer;
  Timer? _throttleTimer;
  Future<T>? _current;
}

sealed class AsyncValue<T> {
  const AsyncValue();

  T get value => (this as Success<T>).value;
  T? get valueOrNull => switch (this) {
        Success(:var value) => value,
        _ => null,
      };

  @override
  String toString() => "$runtimeType";

  @override
  bool operator ==(Object? other) {
    return _equals(other, equals: (a, b) => a == b);
  }

  bool _equals(Object? other, {required Equals<T> equals});
}

class Loading<T> extends AsyncValue<T> {
  final Result<T>? previousResult;
  const Loading({this.previousResult});

  @override
  int get hashCode => runtimeType.hashCode ^ Object.hashAll([previousResult]);

  @override
  String toString() {
    return "$runtimeType(previousResult: $previousResult)";
  }

  @override
  bool _equals(Object? other, {required Equals<T> equals}) {
    if (identical(this, other)) {
      return true;
    }

    if (other is Loading<T> && runtimeType == other.runtimeType) {
      if (previousResult == null && other.previousResult == null) {
        return true;
      } else if (previousResult != null && other.previousResult != null) {
        return previousResult!._equals(other.previousResult!, equals: equals);
      }
    }

    return false;
  }
}

sealed class Result<T> extends AsyncValue<T> {
  const Result();

  static Future<Result<T>> guard<T>(Future<T> Function() computation) async {
    try {
      final result = await computation();
      return Success(result);
    } catch (error, stackTrace) {
      return Failure(error, stackTrace: stackTrace);
    }
  }
}

class Success<T> extends Result<T> {
  const Success(this.value);

  @override
  final T value;

  @override
  T? get valueOrNull => value;

  @override
  bool _equals(Object? other, {required Equals<T> equals}) {
    return identical(this, other) ||
        (other is Success<T> && runtimeType == other.runtimeType && value == other.value);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ Object.hashAll([value]);

  @override
  String toString() => "$runtimeType(value: $value)";
}

class Failure<T> extends Result<T> {
  const Failure(this.error, {this.stackTrace});

  final StackTrace? stackTrace;
  final Object? error;

  @override
  bool _equals(Object? other, {required Equals<T> equals}) {
    return identical(this, other) ||
        other is Failure<T> &&
            runtimeType == other.runtimeType &&
            error == other.error &&
            stackTrace == other.stackTrace;
  }

  @override
  int get hashCode => runtimeType.hashCode ^ Object.hashAll([error, stackTrace]);

  @override
  String toString() => "$runtimeType(error: $error)";
}
