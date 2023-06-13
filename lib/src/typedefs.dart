part of 'core.dart';

typedef Dispose = void Function();
typedef Equals<T> = bool Function(T previous, T next);
typedef Observe = T Function<T>(Observable<T> observable);
