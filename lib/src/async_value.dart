part of 'core.dart';

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
