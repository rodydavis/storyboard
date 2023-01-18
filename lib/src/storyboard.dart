library storyboard;

import 'package:device_frame/device_frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_canvas/infinite_canvas.dart';

import 'custom_rect_clipper.dart';
import 'media_query_observer.dart';
import 'nested_app.dart';
import 'rounded_label.dart';

part 'render_lane.dart';

const _kSpacing = 40.0;
const _kLabelHeight = 65.0;
const _kCompactBreakpoint = 400.0;
const double _MAXSIZE = 100000;
const double _MINSCALE = 0.0001;
const double _STARTSCALE = 0.35;
const _kTitle = 'Storyboard';

typedef ScreenBuilder = Widget Function(
  BuildContext context,
  RouteSettings route,
  Widget child,
);

class StoryBoard extends StatefulWidget {
  const StoryBoard({
    Key? key,
    this.children,
    this.customLanes,
    this.sizedChildren,
    bool showAppBar = false,
    Size childSize = const Size(600, 800),
    this.initialOffset = Offset.zero,
    this.initialScale = _STARTSCALE,
    this.customAppBar,
    this.crossAxisCount,
    this.title = _kTitle,
    this.laneBuilder,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
    this.orientation,
    this.androidDevice,
    this.cupertinoDevice,
    this.deviceFrameStyle,
  })  : _materialApp = null,
        _widgetsApp = null,
        _cupertinoApp = null,
        _widgets = true,
        screenSize = childSize,
        customRoutes = null,
        hideAppBar = !showAppBar,
        enabled = true,
        assert(
            children != null || customLanes != null || sizedChildren != null),
        super(key: key);

  const StoryBoard.app({
    Key? key,
    MaterialApp? materialApp,
    WidgetsApp? widgetsApp,
    CupertinoApp? cupertinoApp,
    List<Widget>? customScreens,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset = Offset.zero,
    this.initialScale = _STARTSCALE,
    this.customLanes,
    this.customAppBar,
    this.customRoutes,
    this.crossAxisCount,
    this.title = _kTitle,
    this.laneBuilder,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
    this.sizedChildren,
    this.orientation,
    this.androidDevice,
    this.cupertinoDevice,
    this.deviceFrameStyle,
  })  : _materialApp = materialApp,
        _widgetsApp = widgetsApp,
        _cupertinoApp = cupertinoApp,
        children = customScreens,
        _widgets = false,
        hideAppBar = false,
        assert(
            materialApp != null || widgetsApp != null || cupertinoApp != null),
        super(key: key);

  const StoryBoard.cupertino({
    Key? key,
    required CupertinoApp child,
    List<Widget>? customScreens,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset = Offset.zero,
    this.initialScale = _STARTSCALE,
    this.customLanes,
    this.customAppBar,
    this.customRoutes,
    this.crossAxisCount,
    this.title = _kTitle,
    this.laneBuilder,
    this.sizedChildren,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
    this.orientation,
    this.androidDevice,
    this.cupertinoDevice,
    this.deviceFrameStyle,
  })  : _materialApp = null,
        _widgetsApp = null,
        _cupertinoApp = child,
        children = customScreens,
        _widgets = false,
        hideAppBar = false,
        super(key: key);

  const StoryBoard.widgets({
    Key? key,
    required WidgetsApp child,
    List<Widget>? customScreens,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset = Offset.zero,
    this.initialScale = _STARTSCALE,
    this.customLanes,
    this.customAppBar,
    this.customRoutes,
    this.crossAxisCount,
    this.title = _kTitle,
    this.laneBuilder,
    this.sizedChildren,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
    this.orientation,
    this.androidDevice,
    this.cupertinoDevice,
    this.deviceFrameStyle,
  })  : _materialApp = null,
        _widgetsApp = child,
        _cupertinoApp = null,
        children = customScreens,
        _widgets = false,
        hideAppBar = false,
        super(key: key);

  const StoryBoard.material({
    Key? key,
    required MaterialApp child,
    List<Widget>? customScreens,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset = Offset.zero,
    this.initialScale = _STARTSCALE,
    this.customLanes,
    this.customAppBar,
    this.customRoutes,
    this.crossAxisCount,
    this.title = _kTitle,
    this.laneBuilder,
    this.sizedChildren,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
    this.orientation,
    this.androidDevice,
    this.cupertinoDevice,
    this.deviceFrameStyle,
  })  : _materialApp = child,
        _widgetsApp = null,
        _cupertinoApp = null,
        children = customScreens,
        _widgets = false,
        hideAppBar = false,
        super(key: key);

  /// Override the default app bar of the storyboard
  final PreferredSizeWidget? customAppBar;

  /// Custom routes you want to show with test data
  final List<RouteSettings>? customRoutes;

  /// Custom screens you want to show
  final List<Widget>? children;

  /// Children that can have custom sizes
  final List<CustomScreen>? sizedChildren;

  /// List of custom lanes
  final List<CustomLane>? customLanes;

  /// You can disable this widget at any time and just return the child
  final bool enabled;

  /// Initial Offset of the canvas
  final Offset initialOffset;

  /// Initial Scale of the canvas
  final double initialScale;

  /// Size for each screen
  final Size screenSize;

  /// Wrap your Cupertino App with this widget
  final CupertinoApp? _cupertinoApp;

  /// Wrap your Material App with this widget
  final MaterialApp? _materialApp;

  /// Wrap your Widgets App with this widget
  final WidgetsApp? _widgetsApp;

  /// Number of widgets to show in a row instead of maxLaneWidth
  final int? crossAxisCount;

  /// Optionally hide the AppBar if used as a widget
  final bool hideAppBar;

  /// Title for AppBar
  final String title;

  /// Optionally wrap the lane building process to customize the look
  final LaneBuilder? laneBuilder;

  /// Label for Custom Screens or Children
  final String? childrenLabel, sizedChildrenLabel;

  /// Use a cupertino device for every screen and ignore the size
  final DeviceInfo? cupertinoDevice;

  /// Use a android device for every screen and ignore the size
  final DeviceInfo? androidDevice;

  /// Device orientation for every screen and ignore the size
  final Orientation? orientation;

  /// Device Frame style
  final DeviceFrameStyle? deviceFrameStyle;

  final bool _widgets;

  @override
  StoryboardController createState() => StoryboardController();
}

class StoryboardController extends State<StoryBoard> {
  final TransformationController _controller = TransformationController();
  late FocusNode _focusNode;
  late InfiniteCanvasController controller;
  Offset _offset = Offset.zero;
  double _scale = 1;
  UniqueKey _key = UniqueKey();

  @override
  void didUpdateWidget(StoryBoard oldWidget) {
    if (oldWidget._widgetsApp != widget._widgetsApp) {
      if (mounted) setState(() {});
    }
    if (oldWidget._materialApp != widget._materialApp) {
      if (mounted) setState(() {});
    }
    if (oldWidget._cupertinoApp != widget._cupertinoApp) {
      if (mounted) setState(() {});
    }
    if (oldWidget.cupertinoDevice != widget.cupertinoDevice) {
      if (mounted) setState(() {});
    }
    if (oldWidget.androidDevice != widget.androidDevice) {
      if (mounted) setState(() {});
    }
    if (oldWidget.orientation != widget.orientation) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _focusNode = FocusNode();
    _controller.value.scale(widget.initialScale);
    final _offset = widget.initialOffset;
    final size = this.size ?? Size(400, 800);
    _controller.value.translate(_offset.dx, _offset.dy);
    controller = InfiniteCanvasController(nodes: [
      // InfiniteCanvasNode(
      //   key: UniqueKey(),
      //   size: Size.square(1),
      //   offset: Offset.zero,
      //   builder: (context) => renderView(),
      // ),
    ]);
    Offset _lastOffset = Offset.zero;
    if (widget._widgets) {
      if (widget.children != null) {
        final lane = _Lane(
          cupertinoDevice: widget.cupertinoDevice,
          androidDevice: widget.androidDevice,
          orientation: widget.orientation,
          laneBuilder: widget.laneBuilder,
          title: widget.childrenLabel ?? '',
          scale: _scale,
          size: size,
          children: widget.children!
              .map(
                (e) => CustomScreen(
                  size: size,
                  child: e,
                ),
              )
              .toList(),
          crossAxisCount: widget.crossAxisCount,
          shadow: const BoxShadow(
            color: Colors.black45,
            offset: Offset(2, 2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        );
        controller.add(lane.toCanvasNode(_lastOffset));
        _lastOffset = _lastOffset.translate(
          0,
          lane.getMaxSize().height + _kSpacing,
        );
      }
      if (widget.sizedChildren != null) {
        final lane = _Lane(
          cupertinoDevice: widget.cupertinoDevice,
          androidDevice: widget.androidDevice,
          orientation: widget.orientation,
          laneBuilder: widget.laneBuilder,
          title: widget.sizedChildrenLabel ?? '',
          scale: _scale,
          size: size,
          children: widget.sizedChildren!,
          crossAxisCount: widget.crossAxisCount,
          shadow: const BoxShadow(
            color: Colors.black45,
            offset: Offset(2, 2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        );
        controller.add(lane.toCanvasNode(_lastOffset));
        _lastOffset = _lastOffset.translate(
          0,
          lane.getMaxSize().height + _kSpacing,
        );
      }
      if (widget.customLanes != null) {
        for (final lane in widget.customLanes!) {
          final newLane = _Lane(
            cupertinoDevice: widget.cupertinoDevice,
            androidDevice: widget.androidDevice,
            orientation: widget.orientation,
            laneBuilder: widget.laneBuilder,
            title: lane.title,
            scale: _scale,
            size: size,
            crossAxisCount: widget.crossAxisCount,
            children: lane.children,
            shadow: const BoxShadow(
              color: Colors.black45,
              offset: Offset(2, 2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          );
          controller.add(newLane.toCanvasNode(_lastOffset));
          _lastOffset = _lastOffset.translate(
            0,
            newLane.getMaxSize().height + _kSpacing,
          );
        }
      }
    } else {
      final rootLane = _Lane(
        cupertinoDevice: widget.cupertinoDevice,
        androidDevice: widget.androidDevice,
        orientation: widget.orientation,
        scale: _scale,
        title: 'Main',
        laneBuilder: widget.laneBuilder,
        size: size,
        crossAxisCount: widget.crossAxisCount,
        children: [
          if (initialRoute != null)
            _addChild(
              RouteSettings(name: initialRoute),
              label: 'Initial Route',
            ),
          if (home != null)
            _addChild(
              null,
              label: 'Home',
              child: home,
            ),
        ],
      );
      controller.add(rootLane.toCanvasNode(_lastOffset));
      _lastOffset = _lastOffset.translate(
        0,
        rootLane.getMaxSize().height + _kSpacing,
      );

      if (routes != null) {
        final routesLane = _Lane(
          cupertinoDevice: widget.cupertinoDevice,
          androidDevice: widget.androidDevice,
          orientation: widget.orientation,
          title: 'Routes',
          scale: _scale,
          laneBuilder: widget.laneBuilder,
          size: size,
          crossAxisCount: widget.crossAxisCount,
          children: [
            for (var i = 0; i < routes!.keys.length; i++)
              _addChild(
                RouteSettings(name: routes!.keys.toList()[i]),
                label: routes!.keys.toList()[i],
              ),
          ],
        );
        controller.add(routesLane.toCanvasNode(_lastOffset));
        _lastOffset = _lastOffset.translate(
          0,
          routesLane.getMaxSize().height + _kSpacing,
        );
      }

      if (widget.children != null) {
        final childrenLane = _Lane(
          cupertinoDevice: widget.cupertinoDevice,
          androidDevice: widget.androidDevice,
          orientation: widget.orientation,
          laneBuilder: widget.laneBuilder,
          title: widget.childrenLabel ?? '',
          scale: _scale,
          size: size,
          children: widget.children!
              .map((e) => _addChild(
                    null,
                    label: null,
                    child: e,
                    customWidget: true,
                  ))
              .toList(),
          crossAxisCount: widget.crossAxisCount,
        );
        controller.add(childrenLane.toCanvasNode(_lastOffset));
        _lastOffset = _lastOffset.translate(
          0,
          childrenLane.getMaxSize().height + _kSpacing,
        );
      }

      if (widget.customRoutes != null) {
        final customRoutesLane = _Lane(
          cupertinoDevice: widget.cupertinoDevice,
          androidDevice: widget.androidDevice,
          orientation: widget.orientation,
          laneBuilder: widget.laneBuilder,
          title: 'Custom Routes',
          scale: _scale,
          size: size,
          crossAxisCount: widget.crossAxisCount,
          children: [
            for (var i = 0; i < widget.customRoutes!.length; i++)
              _addChild(
                widget.customRoutes![i],
                label: widget.customRoutes![i].name,
              ),
          ],
        );
        controller.add(customRoutesLane.toCanvasNode(_lastOffset));
        _lastOffset = _lastOffset.translate(
          0,
          customRoutesLane.getMaxSize().height + _kSpacing,
        );
      }

      if (widget.customLanes != null) {
        for (final lane in widget.customLanes!) {
          final newLane = _Lane(
            cupertinoDevice: widget.cupertinoDevice,
            androidDevice: widget.androidDevice,
            orientation: widget.orientation,
            laneBuilder: widget.laneBuilder,
            title: lane.title,
            scale: _scale,
            size: size,
            crossAxisCount: widget.crossAxisCount,
            children: lane.children,
            shadow: const BoxShadow(
              color: Colors.black45,
              offset: Offset(2, 2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          );
          controller.add(newLane.toCanvasNode(_lastOffset));
          _lastOffset = _lastOffset.translate(
            0,
            newLane.getMaxSize().height + _kSpacing,
          );
        }
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void restart() {
    _key = UniqueKey();
    if (mounted) setState(() {});
  }

  Widget get app {
    if (materialApp != null) return materialApp!;
    if (widgetsApp != null) return widgetsApp!;
    if (cupertinoApp != null) return cupertinoApp!;
    return Container();
  }

  MaterialApp? get materialApp => widget._materialApp;
  WidgetsApp? get widgetsApp => widget._widgetsApp;
  CupertinoApp? get cupertinoApp => widget._cupertinoApp;

  Widget? get home {
    if (materialApp != null) return materialApp?.home;
    if (widgetsApp != null) return widgetsApp?.home;
    if (cupertinoApp != null) return cupertinoApp?.home;
    return null;
  }

  Map<String, WidgetBuilder>? get routes {
    if (materialApp != null) return materialApp?.routes;
    if (widgetsApp != null) return widgetsApp?.routes;
    if (cupertinoApp != null) return cupertinoApp?.routes;
    return null;
  }

  String? get initialRoute {
    if (materialApp != null) return materialApp?.initialRoute;
    if (widgetsApp != null) return widgetsApp?.initialRoute;
    if (cupertinoApp != null) return cupertinoApp?.initialRoute;
    return null;
  }

  Size? get size {
    return Size(
      widget.screenSize.width,
      widget.screenSize.height + _kLabelHeight,
    );
  }

  CustomScreen _addChild(
    RouteSettings? route, {
    Widget? child,
    String? label,
    bool customWidget = false,
    Size? customSize,
  }) {
    final Size _size = customSize ?? widget.screenSize;
    return CustomScreen(
      size: size,
      child: _buildApp(_size, route, child, customWidget),
    );
  }

  Widget _buildApp(
    Size _size,
    RouteSettings? route,
    Widget? child,
    bool customWidget,
  ) {
    return Material(
      elevation: 2,
      child: SizedBox.fromSize(
        size: _size,
        child: ClipRect(
          clipper: CustomRect(const Offset(0, 0)),
          child: NestedApp(
            route: route,
            size: _size,
            customWidget: customWidget,
            materialApp: materialApp,
            cupertinoApp: cupertinoApp,
            widgetsApp: widgetsApp,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return app;
    return MaterialApp(
      key: _key,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) => DeviceFrameTheme(
          style: widget.deviceFrameStyle ?? DeviceFrameStyle.dark(),
          child: LayoutBuilder(
            builder: (context, dimens) => Scaffold(
              appBar: _buildAppBar(dimens.maxWidth <= _kCompactBreakpoint),
              body: InfiniteCanvas(
                minScale: 0.2,
                controller: controller,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget renderView() {
  //   return Stack(
  //     fit: StackFit.expand,
  //     // overflow: Overflow.visible,
  //     clipBehavior: Clip.none,
  //     children: [
  //       if (widget._widgets)
  //         Positioned(
  //           top: _offset.dy,
  //           left: _offset.dx,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               if (widget.children != null)
  //                 _Lane(
  //                   cupertinoDevice: widget.cupertinoDevice,
  //                   androidDevice: widget.androidDevice,
  //                   orientation: widget.orientation,
  //                   laneBuilder: widget.laneBuilder,
  //                   title: widget.childrenLabel ?? '',
  //                   scale: _scale,
  //                   size: size,
  //                   children: widget.children!
  //                       .map(
  //                         (e) => CustomScreen(
  //                           size: size,
  //                           child: e,
  //                         ),
  //                       )
  //                       .toList(),
  //                   crossAxisCount: widget.crossAxisCount,
  //                   shadow: const BoxShadow(
  //                     color: Colors.black45,
  //                     offset: Offset(2, 2),
  //                     blurRadius: 10,
  //                     spreadRadius: 2,
  //                   ),
  //                 ),
  //               if (widget.sizedChildren != null)
  //                 _Lane(
  //                   cupertinoDevice: widget.cupertinoDevice,
  //                   androidDevice: widget.androidDevice,
  //                   orientation: widget.orientation,
  //                   laneBuilder: widget.laneBuilder,
  //                   title: widget.sizedChildrenLabel ?? '',
  //                   scale: _scale,
  //                   size: size,
  //                   children: widget.sizedChildren!,
  //                   crossAxisCount: widget.crossAxisCount,
  //                   shadow: const BoxShadow(
  //                     color: Colors.black45,
  //                     offset: Offset(2, 2),
  //                     blurRadius: 10,
  //                     spreadRadius: 2,
  //                   ),
  //                 ),
  //               if (widget.customLanes != null)
  //                 for (final lane in widget.customLanes!)
  //                   _Lane(
  //                     cupertinoDevice: widget.cupertinoDevice,
  //                     androidDevice: widget.androidDevice,
  //                     orientation: widget.orientation,
  //                     laneBuilder: widget.laneBuilder,
  //                     title: lane.title,
  //                     scale: _scale,
  //                     size: size,
  //                     crossAxisCount: widget.crossAxisCount,
  //                     children: lane.children,
  //                     shadow: const BoxShadow(
  //                       color: Colors.black45,
  //                       offset: Offset(2, 2),
  //                       blurRadius: 10,
  //                       spreadRadius: 2,
  //                     ),
  //                   ),
  //             ],
  //           ),
  //         ),
  //       if (!widget._widgets) ...[
  //         Positioned(
  //           top: _offset.dy,
  //           left: _offset.dx,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               _Lane(
  //                 cupertinoDevice: widget.cupertinoDevice,
  //                 androidDevice: widget.androidDevice,
  //                 orientation: widget.orientation,
  //                 scale: _scale,
  //                 title: 'Main',
  //                 laneBuilder: widget.laneBuilder,
  //                 size: size,
  //                 crossAxisCount: widget.crossAxisCount,
  //                 children: [
  //                   if (initialRoute != null)
  //                     _addChild(
  //                       RouteSettings(name: initialRoute),
  //                       label: 'Initial Route',
  //                     ),
  //                   if (home != null)
  //                     _addChild(
  //                       null,
  //                       label: 'Home',
  //                       child: home,
  //                     ),
  //                 ],
  //               ),
  //               if (routes != null)
  //                 _Lane(
  //                   cupertinoDevice: widget.cupertinoDevice,
  //                   androidDevice: widget.androidDevice,
  //                   orientation: widget.orientation,
  //                   title: 'Routes',
  //                   scale: _scale,
  //                   laneBuilder: widget.laneBuilder,
  //                   size: size,
  //                   crossAxisCount: widget.crossAxisCount,
  //                   children: [
  //                     for (var i = 0; i < routes!.keys.length; i++)
  //                       _addChild(
  //                         RouteSettings(name: routes!.keys.toList()[i]),
  //                         label: routes!.keys.toList()[i],
  //                       ),
  //                   ],
  //                 ),
  //               if (widget.children != null)
  //                 _Lane(
  //                   cupertinoDevice: widget.cupertinoDevice,
  //                   androidDevice: widget.androidDevice,
  //                   orientation: widget.orientation,
  //                   laneBuilder: widget.laneBuilder,
  //                   title: widget.childrenLabel ?? '',
  //                   scale: _scale,
  //                   size: size,
  //                   children: widget.children!
  //                       .map((e) => _addChild(
  //                             null,
  //                             label: null,
  //                             child: e,
  //                             customWidget: true,
  //                           ))
  //                       .toList(),
  //                   crossAxisCount: widget.crossAxisCount,
  //                 ),
  //               if (widget.customRoutes != null)
  //                 _Lane(
  //                   cupertinoDevice: widget.cupertinoDevice,
  //                   androidDevice: widget.androidDevice,
  //                   orientation: widget.orientation,
  //                   laneBuilder: widget.laneBuilder,
  //                   title: 'Custom Routes',
  //                   scale: _scale,
  //                   size: size,
  //                   crossAxisCount: widget.crossAxisCount,
  //                   children: [
  //                     for (var i = 0; i < widget.customRoutes!.length; i++)
  //                       _addChild(
  //                         widget.customRoutes![i],
  //                         label: widget.customRoutes![i].name,
  //                       ),
  //                   ],
  //                 ),
  //               if (widget.customLanes != null)
  //                 for (final lane in widget.customLanes!)
  //                   _Lane(
  //                     cupertinoDevice: widget.cupertinoDevice,
  //                     androidDevice: widget.androidDevice,
  //                     orientation: widget.orientation,
  //                     laneBuilder: widget.laneBuilder,
  //                     title: lane.title,
  //                     scale: _scale,
  //                     size: size,
  //                     crossAxisCount: widget.crossAxisCount,
  //                     children: lane.children
  //                         .map((e) => _addChild(
  //                               null,
  //                               label: e.label,
  //                               child: e.child,
  //                               customSize: e.size,
  //                               customWidget: true,
  //                             ))
  //                         .toList(),
  //                   ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ],
  //   );
  // }

  PreferredSizeWidget? _buildAppBar([bool compact = false]) {
    const kRestartKey = 0;
    const kResetKey = 1;
    const kZoomInKey = 2;
    const kZoomOutKey = 4;
    if (widget.hideAppBar) {
      return null;
    } else {
      return widget.customAppBar ??
          AppBar(
            title: const Text(_kTitle),
            actions: compact
                ? [
                    PopupMenuButton<int>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: kRestartKey,
                          child: Text('Restart App'),
                        ),
                      ],
                      onSelected: (val) {
                        if (val == kRestartKey) {
                          restart();
                        }
                      },
                    ),
                  ]
                : [
                    IconButton(
                      tooltip: 'Restart App',
                      icon: const Icon(Icons.refresh),
                      onPressed: restart,
                    ),
                  ],
          );
    }
  }
}
