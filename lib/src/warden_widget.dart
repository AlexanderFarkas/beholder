part of 'core.dart';

class Warden extends StatefulWidget {
  const Warden({Key? key, required this.builder}) : super(key: key);
  final Widget Function(BuildContext context, Observe watch) builder;

  @override
  State<Warden> createState() => _WardenState();
}

class _WardenState extends State<Warden> with Observer {
  late final watcher = Observatory(this);

  @override
  Widget build(BuildContext context) {
    return watcher.proxy((watch) => widget.builder(context, watch));
  }

  @override
  void dispose() {
    watcher.dispose();
    super.dispose();
  }

  @override
  void performUpdate() => setState(() {});
}
