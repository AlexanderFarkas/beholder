part of '../core.dart';

enum ScopePhase {
  markNeedsUpdate,
  notify,
}

class NotificationScope {
  static NotificationScope? _current;
  static void markNeedsUpdate(ObservableState observable) {
    final scope = _current;
    if (scope != null && scope.phase == ScopePhase.notify) {
      assert(
        scope._observers.containsKey(observable.delegatedByObserver),
        "Observable value was set synchronously during ScopePhase.notify.\nTry wrapping mutating code in Future.microtask.",
      );

      return;
    }

    _current ??= NotificationScope._();
    NotificationScope._current!._markObservableStateNeedsUpdate(observable);
  }

  NotificationScope._();

  final observableStates = <ObservableState>{};
  ScopePhase phase = ScopePhase.markNeedsUpdate;

  final Map<ObserverMixin, int> _observers = {};
  void _markObservableStateNeedsUpdate(ObservableState observable) {
    if (observable.observers.isEmpty || !observableStates.add(observable)) {
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
        for (final observer in observer.observers) {
          inner(observer, level + 1);
        }
      }
    }

    for (final observer in observable.observers) {
      inner(observer, 0);
    }
  }

  void updateObservers() {
    phase = ScopePhase.notify;
    final queue = Queue<_Node>();
    for (final observable in observableStates) {
      queue.addAll(observable.observers.map((e) => _Node(level: 0, observer: e)));
      while (queue.isNotEmpty) {
        final _Node(:observer, :level) = queue.removeFirst();
        final updateLevel = _observers[observer];
        if (updateLevel != level) continue;

        final isUpdated = observer.update();
        if (observer is ObservableObserver) {
          for (final observer in observer.observers) {
            if (!isUpdated) observer.undoMarkNeedsUpdate();
            queue.add(_Node(level: level + 1, observer: observer));
          }
        }
      }
    }
    NotificationScope._current = null;
  }
}

class _Node {
  final int level;
  final ObserverMixin observer;

  _Node({required this.level, required this.observer});
}
