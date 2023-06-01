import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

typedef DisposeFn = void Function();

class Store {
  @protected
  final onDispose = <DisposeFn>{};

  @protected
  ObservableValue<T> observable<T>(T value, {EqualFn<T>? equals}) {
    final observable = ObservableValue<T>(value, equals: equals);
    onDispose.add(observable.dispose);
    return observable;
  }

  @protected
  Computed<T> computed<T>(T Function(WatcherConsumer watcher) compute, {EqualFn<T>? equals}) {
    final computed = Computed(compute, equals: equals);
    onDispose.add(computed.dispose);
    return computed;
  }

  @mustCallSuper
  void dispose() {
    for (final disposer in onDispose) {
      disposer();
    }
  }
}

typedef ValueChanged = void Function();

abstract class Observable<T> with Diagnosticable {
  static bool debugEnabled = false;
  static bool defaultEquals(Object? previous, Object? next) {
    return previous == next;
  }

  final _observers = <Observer>{};
  late final Lazy<StreamController<T>> _controller = Lazy(
    () {
      final controller = StreamController<T>.broadcast();
      listen((value) => controller.add(value));
      return controller;
    },
    dispose: (controller) => controller.close(),
  );

  T get value;
  Stream<T> get stream => _controller.get().stream;
  bool _debugDisposed = false;

  void addObserver(Observer observer) {
    assert(!_debugDisposed);
    assert(() {
      if (!_observers.contains(observer)) {
        log("Observer[$observer] added to observable[$this]");
      }
      return true;
    }());
    _observers.add(observer);
  }

  void removeObserver(Observer observer) {
    assert(() {
      if (_observers.contains(observer)) {
        log("Observer[$observer] removed from [$this]");
      }
      return true;
    }());
    _observers.remove(observer);
  }

  DisposeFn listen(void Function(T value) onChanged) {
    final observer = InlineObserver(() => onChanged(value));
    addObserver(observer);
    return () => removeObserver(observer);
  }

  @mustCallSuper
  dispose() {
    assert(() {
      _debugDisposed = true;
      log("Observable[$this] disposed");
      return true;
    }());
    _controller.dispose();
    _observers.clear();
  }
}

mixin Observer {
  @protected
  void performUpdate();

  void update() {
    if (_needsUpdate) {
      performUpdate();
      _needsUpdate = false;
      assert(() {
        log("$this updated");
        return true;
      }());
    }
  }

  bool _needsUpdate = false;

  @mustCallSuper
  void markNeedsUpdate() => _needsUpdate = true;
}

typedef EqualFn<T> = bool Function(T previous, T next);

class ObservableValue<T> extends Observable<T> {
  ObservableValue(T value, {EqualFn<T>? equals})
      : _value = value,
        equals = equals ?? Observable.defaultEquals;

  final EqualFn<T> equals;
  T _value;

  @override
  T get value => _value;
  set value(T value) {
    final oldValue = _value;
    _value = value;
    if (!equals(oldValue, _value)) {
      _markObserversNeedUpdate();
      _notifyObservers();
    }
  }

  T update(T Function(T previous) updater) {
    value = updater(value);
    return value;
  }

  void _markObserversNeedUpdate() {
    for (final observer in _observers) {
      observer.markNeedsUpdate();
    }
  }

  void _notifyObservers() {
    assert(() {
      log("Observable($this) notifies observers");
      return true;
    }());
    final childQueue = Queue<Observer>();

    childQueue.addAll(_observers);

    while (childQueue.isNotEmpty) {
      final observer = childQueue.removeFirst();
      observer.update();
      if (observer case Observable(_observers: var observers)) {
        childQueue.addAll(observers);
      }
    }
  }
}

typedef Watch<T> = T Function(Observable<T> observable);

abstract class WatcherConsumer {
  T watch<T>(Observable<T> observable);
  T call<T>(Observable<T> observable);
}

class Watcher implements WatcherConsumer {
  final observables = <Observable>{};

  @override
  T watch<T>(Observable<T> observable) {
    observables.add(observable);
    return observable.value;
  }

  @override
  T call<T>(Observable<T> observable) => watch(observable);

  start<TResult>(Observer observer, {required TResult Function(WatcherConsumer) perform}) {
    final oldObservables = {...observables};

    observables.clear();
    final result = perform(this);
    for (final observable in observables) {
      oldObservables.remove(observable);
      observable.addObserver(observer);
    }

    for (final observable in oldObservables) {
      observable.removeObserver(observer);
    }

    return result;
  }
}

class Computed<T> extends Observable<T> with Observer {
  final T Function(WatcherConsumer watcher) compute;
  final watcher = Watcher();
  Computed(this.compute, {EqualFn<T>? equals}) : equals = equals ?? Observable.defaultEquals {
    _value = watcher.start(this, perform: compute);
  }

  final EqualFn<T> equals;
  late T _value;

  @override
  T get value => _value;

  @override
  void performUpdate() {
    final oldValue = _value;
    _value = watcher.start(this, perform: compute);

    if (!equals(oldValue, _value)) {
      for (final observer in _observers) {
        observer.markNeedsUpdate();
      }
    }
  }
}

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

class InlineObserver with Observer, Diagnosticable {
  InlineObserver(this.listener);
  final void Function() listener;

  @override
  void performUpdate() => listener();
}

log(String message) {
  if (Observable.debugEnabled) {
    developer.log(message);
  }
}
