part of 'core.dart';

enum ScopePhase {
  markNeedsUpdate,
  notify,
}

class NotificationScope {
  static NotificationScope? _current;
  static void markNeedsUpdate(Observable observable) {
    final scope = _current;
    if (scope != null && scope.phase == ScopePhase.notify) {
      assert(
        scope._observers.containsKey(observable),
        "Observable value was set synchronously during ScopePhase.notify.\nTry wrapping mutating code in Future.microtask.",
      );

      return;
    }

    scopedUpdate(() => NotificationScope._current!._markObservableNeedsUpdate(observable));
  }

  NotificationScope._();

  final observables = <Observable>{};
  ScopePhase phase = ScopePhase.markNeedsUpdate;

  final Map<ObserverMixin, int> _observers = {};
  void _markObservableNeedsUpdate(Observable observable) {
    if (!observables.add(observable)) {
      return;
    }

    void inner(ObserverMixin observer, int level) {
      _observers.update(
        observer,
        (value) => math.max(value, level),
        ifAbsent: () => level,
      );
      observer.markNeedsUpdate();

      if (observer is ObservableObserver) {
        for (final observer in observer._observers) {
          inner(observer, level + 1);
        }
      }
    }

    for (final observer in observable.observers) {
      inner(observer, 0);
    }
  }

  void _updateObservers() {
    phase = ScopePhase.notify;
    final queue = Queue<_Node>();
    for (final observable in observables) {
      print(_observers);
      queue.addAll(observable.observers.map((e) => _Node(level: 0, observer: e)));
      while (queue.isNotEmpty) {
        final _Node(:observer, :level) = queue.removeFirst();
        final updateLevel = _observers[observer];
        if (updateLevel != level) continue;

        final isUpdated = observer._update();
        if (isUpdated && observer is ObservableObserver) {
          queue.addAll(observer.observers.map((e) => _Node(level: level + 1, observer: e)));
        }
      }
    }
  }
}

void scopedUpdate(void Function() callback) {
  final isOuter = NotificationScope._current == null;
  if (isOuter) {
    NotificationScope._current = NotificationScope._();
  }

  assert(
    NotificationScope._current!.phase == ScopePhase.markNeedsUpdate,
    "Scoped update was called during update. Wrap calling code in Future.microtask",
  );
  callback();

  if (isOuter) {
    NotificationScope._current!._updateObservers();
    NotificationScope._current = null;
  }
}

class _Node {
  final int level;
  final ObserverMixin observer;

  _Node({required this.level, required this.observer});
}
