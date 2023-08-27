import 'package:flutter/widgets.dart';

import 'core.dart';

class Observer extends StatefulWidget {
  const Observer({Key? key, required this.builder}) : super(key: key);
  final Widget Function(BuildContext context, Watch watch) builder;

  @override
  State<Observer> createState() => _ObserverState();
}

class _ObserverState extends State<Observer> with ObserverMixin {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, observe);
  }

  @override
  void dispose() {
    stopObserving();
    super.dispose();
  }

  @override
  bool performUpdate() {
    setState(() {});
    return true;
  }
}
