library warden;

import 'package:flutter/widgets.dart';
import 'package:warden/warden_mixin.dart';

class Warden extends StatefulWidget {
  const Warden({Key? key, required this.builder}) : super(key: key);
  final Widget Function(BuildContext context, WatcherConsumer watch) builder;

  @override
  State<Warden> createState() => _WardenState();
}

class _WardenState extends State<Warden> with Observer {
  final watcher = Watcher();
  @override
  Widget build(BuildContext context) {
    return watcher.start(
      this,
      perform: (watch) => widget.builder(context, watch),
    );
  }

  @override
  void dispose() {
    for (final observable in watcher.observables) {
      observable.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void performUpdate() => setState(() {});
}
