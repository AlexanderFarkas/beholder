part of '../core.dart';

class ObservableState<T> extends BaseObservable<T> implements WritableObservable<T> {
  ObservableState(T value, {Equals<T>? equals})
      : _value = value,
        _equals = equals ?? Observable.defaultEquals;

  @override
  T get value => _value;
  set value(T value) {
    final oldValue = _value;
    _value = value;
    final willUpdate = !_equals(oldValue, value);
    if (willUpdate) {
      scopedUpdate(() {
        NotificationScope.markNeedsUpdate(this);
        for (final listener in _eagerListeners) {
          listener(value);
        }
      });
    }
  }

  T update(T Function(T previous) updater) {
    value = updater(value);
    return value;
  }

  @override
  Dispose listen(ValueChanged<T> onChanged, {ScopePhase phase = ScopePhase.notify}) {
    if (phase == ScopePhase.notify) {
      return super.listen(onChanged);
    } else {
      final isNew = _eagerListeners.add(onChanged);
      assert(isNew, "Listener already added");
      return () => _eagerListeners.remove(onChanged);
    }
  }

  final Equals<T> _equals;

  T _value;
  final _eagerListeners = <ValueChanged<T>>{};

  @override
  void dispose() {
    _eagerListeners.clear();
    super.dispose();
  }
}
