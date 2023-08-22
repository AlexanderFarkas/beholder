part of '../core.dart';

class ObservableScope {
  static ObservableScope? _current;
  static void markNeedsUpdate(Observable observable) {
    final scope = _current;
    if (scope != null && scope.isExiting) {
      assert(scope._observers.containsKey(observable), """
          Observable value was set synchronously after other Observable has performed update.
          Try wrapping mutating code in Future.microtask.
          """);

      return;
    }

    scopedUpdate(() => _current?._markObservableNeedsUpdate(observable));
  }

  ObservableScope._();

  final observables = <Observable>{};
  bool isExiting = false;

  int counter = 0;
  void enter() {
    counter++;
  }

  final Map<Observer, int> _observers = {};
  void _markObservableNeedsUpdate(Observable observable) {
    void inner(Observer observer, int level) {
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

    for (final observer in observable._observers) {
      inner(observer, 0);
    }
    observables.add(observable);
  }

  void _exit() {
    counter--;

    if (counter == 0) {
      isExiting = true;
      final queue = Queue<_Node>();
      for (final observable in observables) {
        queue.addAll(observable._observers.map((e) => _Node(level: 0, observer: e)));
        while (queue.isNotEmpty) {
          final _Node(:observer, :level) = queue.removeFirst();
          final updateLevel = _observers[observer];
          if (updateLevel != level) continue;

          final isUpdated = observer._update();
          if (isUpdated && observer is ObservableObserver) {
            queue.addAll(observer._observers.map((e) => _Node(level: level + 1, observer: e)));
          }
        }
      }

      ObservableScope._current = null;
    }
  }
}

scopedUpdate(void Function() callback) {
  ObservableScope._current ??= ObservableScope._();
  assert(
    ObservableScope._current?.isExiting != true,
    "Scoped update was called during update. Wrap calling code in Future.microtask",
  );
  ObservableScope._current!.enter();
  callback();
  ObservableScope._current!._exit();
}

class _Node {
  final int level;
  final Observer observer;

  _Node({required this.level, required this.observer});
}
