part of 'core.dart';

class Observer extends StatefulWidget {
  const Observer({Key? key, required this.builder}) : super(key: key);
  final Widget Function(BuildContext context, Watch watch) builder;

  @override
  State<Observer> createState() => _ObserverState();
}

class _ObserverState extends State<Observer> {
  late final observer = InlineObserver(() => setState(() {}), debugLabel: "ObserverWidget");

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, observer.observe);
  }

  @override
  void dispose() {
    observer.dispose();
    super.dispose();
  }
}
