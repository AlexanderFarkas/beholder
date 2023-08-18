part of 'core.dart';

class Warden extends StatefulWidget {
  const Warden({Key? key, required this.builder}) : super(key: key);
  final Widget Function(BuildContext context, Observe observe) builder;

  @override
  State<Warden> createState() => _WardenState();
}

class _WardenState extends State<Warden> with Observer {
  late final observatory = Observatory(this);

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, observatory.observe);
  }

  @override
  void dispose() {
    observatory.dispose();
    super.dispose();
  }

  @override
  void performUpdate() => setState(() {});
}
