import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'core.dart';

@internal
debugLog(String message) {
  if (Observable.debugEnabled) {
    developer.log(message);
  }
}

@internal
class Lazy<T> {
  final T Function() builder;
  final void Function(T)? _dispose;

  Lazy(this.builder, {void Function(T)? dispose}) : _dispose = dispose;

  late T _value;
  bool isInitialized = false;
  T get() {
    if (!isInitialized) {
      _value = builder();
      isInitialized = true;
    }
    return _value;
  }

  void dispose() {
    if (_dispose case var dispose? when isInitialized) {
      dispose(_value);
    }
  }
}

@internal
mixin DebugReprMixin {
  String? debugLabel;

  @override
  String toString() {
    if (Observable.debugEnabled) {
      return "${debugLabel ?? runtimeType}#${hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0')}";
    }

    return super.toString();
  }
}
