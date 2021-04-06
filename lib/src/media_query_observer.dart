import 'package:flutter/widgets.dart';

class MediaQueryObserver extends StatefulWidget {
  final Widget child;
  final MediaQueryData? data;

  const MediaQueryObserver({
    required this.child,
    required this.data,
  });

  @override
  _MediaQueryObserverState createState() => _MediaQueryObserverState();
}

class _MediaQueryObserverState extends State<MediaQueryObserver>
    with WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    setState(() {});
    super.didChangeMetrics();
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: widget.data ??
          MediaQueryData.fromWindow(WidgetsBinding.instance!.window),
      child: widget.child,
    );
  }
}
