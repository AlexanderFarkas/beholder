part of 'core.dart';

mixin ObserverMixin {
  final observables = <Observable>{};

  @protected
  bool performUpdate();

  bool _update() {
    assert(() {
      log("$this notified");
      return true;
    }());
    if (!needsUpdate) return false;

    needsUpdate = false;
    final isUpdated = performUpdate();
    assert(() {
      log("$this updated");
      return true;
    }());
    return isUpdated;
  }

  T observe<T>(Observable<T> observable) {
    observables.add(observable);
    observable.addObserver(this);
    return observable.value;
  }

  @protected
  bool needsUpdate = false;

  void markNeedsUpdate() => needsUpdate = true;

  void dispose() {
    for (final observable in observables) {
      observable.removeObserver(this);
    }
  }
}

class InlineObserver with ObserverMixin {
  InlineObserver(this.listener, {this.debugLabel});
  final void Function() listener;
  final String? debugLabel;

  @override
  bool performUpdate() {
    listener();
    return true;
  }

  @override
  String toString() => "${debugLabel ?? runtimeType}${shortHash(this)}";
}
