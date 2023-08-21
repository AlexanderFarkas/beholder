part of '../core.dart';

class ObservableFuture<T> extends ObservableObserver<AsyncValue<T>> {
  final bool _keepPrevious;
  final Future<T> Function(Observe observe) _compute;
  final Duration _debounceTime;
  final Duration _throttleTime;
  final Equals<T> _equals;

  ObservableFuture._(
    this._compute, {
    bool? keepPrevious,
    AsyncValue<T>? initial,
    Duration? debounceTime,
    Duration? throttleTime,
    Equals<T>? equals,
  })  : _keepPrevious = keepPrevious ?? false,
        _value = initial ?? const Loading(),
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
        switch (_value) {
          Success(:var value) when _keepPrevious => LoadingWithPreviousData(value),
          LoadingWithPreviousData() => _value,
          _ => const FreshLoading(),
        },
      );

  bool _setValue(AsyncValue<T> value) {
    final oldValue = _value;
    _value = value;

    if (!_valueEquals(oldValue, _value)) {
      ObservableScope.markNeedsUpdate(this);
      return true;
    }

    return false;
  }

  bool _valueEquals(AsyncValue<T> v1, AsyncValue<T> v2) {
    if (v1.runtimeType != v2.runtimeType) {
      return false;
    }

    if (identical(v1, v2)) {
      return true;
    }

    return switch (v1) {
      Success(:var value) => _equals(value, v2.value),
      LoadingWithPreviousData(:var previousData) =>
        _equals(previousData, (v2 as LoadingWithPreviousData<T>).previousData),
      _ => v1 == v2,
    };
  }

  void _cancelThrottle() {
    _throttleTimer?.cancel();
    _throttleTimer = null;
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

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
}

sealed class Loading<T> extends AsyncValue<T> {
  const Loading._();
  const factory Loading() = FreshLoading<T>;
}

class FreshLoading<T> extends Loading<T> {
  const FreshLoading() : super._();
}

class LoadingWithPreviousData<T> extends Loading<T> {
  const LoadingWithPreviousData(this.previousData) : super._();

  final T previousData;

  @override
  bool operator ==(Object other) {
    return identical(this, other) &&
        other is LoadingWithPreviousData<T> &&
        runtimeType == other.runtimeType &&
        previousData == other.previousData;
  }

  @override
  int get hashCode => runtimeType.hashCode ^ Object.hashAll([previousData]);
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
  bool operator ==(Object other) {
    return identical(this, other) &&
        other is Success<T> &&
        runtimeType == other.runtimeType &&
        value == other.value;
  }

  @override
  int get hashCode => runtimeType.hashCode ^ Object.hashAll([value]);
}

class Failure<T> extends Result<T> {
  const Failure(this.error, {this.stackTrace});

  final StackTrace? stackTrace;
  final Object? error;

  @override
  bool operator ==(Object other) {
    return identical(this, other) &&
        other is Failure<T> &&
        runtimeType == other.runtimeType &&
        error == other.error &&
        stackTrace == other.stackTrace;
  }

  @override
  int get hashCode => runtimeType.hashCode ^ Object.hashAll([error, stackTrace]);
}
