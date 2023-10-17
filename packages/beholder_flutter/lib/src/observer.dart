import 'package:beholder/beholder.dart';
import 'package:flutter/widgets.dart';

typedef ObserverBuilder = Widget Function(BuildContext context, Watch watch);

class Observer extends StatefulWidget {
  const Observer({Key? key, required this.builder}) : super(key: key);
  final ObserverBuilder builder;

  @override
  State<Observer> createState() => _ObserverState();
}

class _ObserverState extends State<Observer> with ObserverMixin {
  @override
  Widget build(BuildContext context) {
    return observe((watch) => widget.builder(context, watch));
  }

  @override
  void dispose() {
    stopObserving();
    super.dispose();
  }

  @override
  bool Function() performRebuild() {
    return () {
      setState(() {});
      return true;
    };
  }
}
