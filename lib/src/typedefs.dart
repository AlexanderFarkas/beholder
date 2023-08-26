part of 'core.dart';

typedef Dispose = void Function();
typedef ValueChanged<T> = void Function(T value);
typedef Equals<T> = bool Function(T previous, T next);
typedef Watch = T Function<T>(Observable<T> observable);
