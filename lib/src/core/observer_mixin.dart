part of '../core.dart';

typedef Watch = T Function<T>(Observable<T> observable);

mixin ObserverMixin {
  final observables = <Observable>{};

  @protected
  bool performUpdate();

  @internal
  bool update() {
    final bool isUpdated;
    if (needsUpdate) {
      _markCount = 0;
      isUpdated = performUpdate();
      assert(() {
        debugLog("Notified $this. Is updated: $isUpdated");
        return true;
      }());
    } else {
      isUpdated = false;
    }

    return isUpdated;
  }

  T observe<T>(Observable<T> observable) {
    observables.add(observable);
    observable.addObserver(this);
    return observable.value;
  }

  @protected
  bool get needsUpdate => _markCount > 0;
  int _markCount = 0;

  void markNeedsUpdate() => _markCount++;
  void undoMarkNeedsUpdate() => _markCount--;

  void stopObserving() {
    for (final observable in observables) {
      observable.removeObserver(this);
    }
  }
}

class ListenObserver with ObserverMixin, DebugReprMixin {
  ListenObserver(this.listener);
  final void Function() listener;

  @override
  bool performUpdate() {
    listener();
    return true;
  }
}
