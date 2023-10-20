// ignore_for_file: hash_and_equals
part of future;

sealed class AsyncValue<T> {
  const AsyncValue();

  T get value => (this as Success<T>).value;
  T? get valueOrNull => switch (this) {
        Success(:var value) => value,
        _ => null,
      };

  AsyncValue<R> whenValue<R>(R Function(T value) cb) => mapValue(cb);

  R maybeWhen<R>({
    R Function(T value)? data,
    R Function(Object error, StackTrace? stackTrace)? error,
    R Function()? loading,
    required R Function() orElse,
  }) {
    return switch (this) {
      final Success<T> value when data != null => data(value.value),
      final Failure<T> value when error != null =>
        error(value.error, value.stackTrace),
      Loading<T>() when loading != null => loading(),
      _ => orElse(),
    };
  }

  R map<R>({
    required R Function(Success<T> value) data,
    required R Function(Failure<T> value) error,
    required R Function(Loading<T> value) loading,
  }) {
    return switch (this) {
      final Loading<T> value => loading(value),
      final Success<T> value => data(value),
      final Failure<T> value => error(value),
    };
  }

  R when<R>({
    required R Function(T value) data,
    required R Function(Object error, StackTrace? stackTrace) error,
    required R Function() loading,
  }) {
    return switch (this) {
      Loading<T>() => loading(),
      final Success<T> value => data(value.value),
      final Failure<T> value => error(value.error, value.stackTrace),
    };
  }

  AsyncValue<R> mapValue<R>(R Function(T value) cb) {
    return switch (this) {
      final Success<T> value => Success(cb(value.value)),
      final Failure<T> value => Failure(value.error, value.stackTrace),
      Loading<T>() => Loading<R>(),
    };
  }
}

class Loading<T> extends AsyncValue<T> {
  final Result<T>? previousResult;
  const Loading({this.previousResult});
  factory Loading.fromPrevious(AsyncValue<T> previous) {
    return Loading(
      previousResult: switch (previous) {
        Result() && var result => result,
        Loading(previousResult: var result) => result,
      },
    );
  }

  @override
  int get hashCode => runtimeType.hashCode ^ previousResult.hashCode;

  @override
  String toString() {
    return "Loading<$T>(previousResult: $previousResult)";
  }

  @override
  operator ==(Object? other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is Loading<T> && runtimeType == other.runtimeType) {
      if (previousResult == null && other.previousResult == null) {
        return true;
      } else if (previousResult != null && other.previousResult != null) {
        return previousResult! == other.previousResult!;
      }
    }

    return false;
  }
}

sealed class Result<T> extends AsyncValue<T> {
  const Result();

  @override
  Result<R> mapValue<R>(R Function(T value) cb) {
    return super.mapValue(cb) as Result<R>;
  }

  @override
  Result<R> whenValue<R>(R Function(T value) cb) {
    return mapValue(cb);
  }

  static Future<Result<T>> guard<T>(FutureOr<T> Function() computation) async {
    try {
      final result = await computation();
      return Success(result);
    } catch (error, stackTrace) {
      return Failure(error, stackTrace);
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
  operator ==(Object? other) {
    return identical(this, other) ||
        (other is Success<T> &&
            runtimeType == other.runtimeType &&
            value == other.value);
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => "Success<$T>(value: $value)";
}

class Failure<T> extends Result<T> {
  const Failure(this.error, [this.stackTrace]);

  final Object error;
  final StackTrace? stackTrace;

  @override
  operator ==(Object? other) {
    return identical(this, other) ||
        (other is Failure<T> &&
            runtimeType == other.runtimeType &&
            error == other.error &&
            stackTrace == other.stackTrace);
  }

  @override
  int get hashCode => Object.hash(runtimeType, error, stackTrace);

  @override
  String toString() =>
      'Failure<$T>(error: $error, stackTrace: $stackTrace)';
}
