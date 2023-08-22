part of 'core.dart';

// abstract class Observer {
//   void markNeedsUpdate();
//   bool update();
// }

mixin Observer {
  final observables = <Observable>{};

  @protected
  bool performUpdate();

  bool _update() {
    if (!needsUpdate) return false;
    assert(() {
      log("$this notified");
      return true;
    }());
    needsUpdate = false;
    final isUpdated = performUpdate();
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

class InlineObserver with Observer {
  InlineObserver(this.listener);
  final void Function() listener;

  @override
  bool performUpdate() {
    listener();
    return true;
  }

  @override
  String toString() => "$runtimeType${shortHash(this)}";
}
