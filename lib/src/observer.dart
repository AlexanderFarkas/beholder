part of 'core.dart';

mixin Observer {
  @protected
  void performUpdate();

  void update() {
    if (_needsUpdate) {
      assert(() {
        log("$this started update");
        return true;
      }());
      performUpdate();
      _needsUpdate = false;
      assert(() {
        log("$this finished update");
        return true;
      }());
    }
  }

  bool _needsUpdate = false;

  @mustCallSuper
  void markNeedsUpdate() => _needsUpdate = true;
}

class InlineObserver with Observer {
  InlineObserver(this.listener);
  final void Function() listener;

  @override
  void performUpdate() => listener();
}
