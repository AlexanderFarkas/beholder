sealed class AsyncValue<T> {
  const AsyncValue();

  T get value => (this as Success<T>).value;
  T? get valueOrNull => switch (this) {
        Success(:var value) => value,
        _ => null,
      };
}

class Loading<T> extends AsyncValue<T> {
  const Loading();
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
}

class Failure<T> extends Result<T> {
  const Failure(this.error, {this.stackTrace});

  final StackTrace? stackTrace;
  final Object error;
}
