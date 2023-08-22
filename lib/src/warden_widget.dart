part of 'core.dart';

class Warden extends StatefulWidget {
  const Warden({Key? key, required this.builder}) : super(key: key);
  final Widget Function(BuildContext context, Observe watch) builder;

  @override
  State<Warden> createState() => _WardenState();
}

class _WardenState extends State<Warden> {
  late final observer = WardenObserver(() => setState(() {}));

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

class WardenObserver extends InlineObserver {
  WardenObserver(super.listener);
}
