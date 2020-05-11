library storyboard;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'custom_rect_clipper.dart';
import 'media_query_observer.dart';
import 'nested_app.dart';
import 'rounded_label.dart';

part 'render_lane.dart';

const _kSpacing = 40.0;
const _kLabelHeight = 65.0;
const _kCompactBreakpoint = 400.0;
const _kTitle = 'Storyboard';

typedef ScreenBuilder = Widget Function(
    BuildContext context, RouteSettings route, Widget child);

class StoryBoard extends StatefulWidget {
  const StoryBoard({
    Key key,
    this.children,
    this.customLanes,
    this.sizedChildren,
    bool showAppBar = false,
    Size childSize,
    this.initialOffset,
    this.initialScale,
    this.usePreferences = false,
    this.customAppBar,
    this.crossAxisCount,
    this.title = _kTitle,
    this.laneBuilder,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
  })  : _materialApp = null,
        _widgetsApp = null,
        _cupertinoApp = null,
        _widgets = true,
        screenBuilder = null,
        screenSize = childSize,
        customRoutes = null,
        hideAppBar = !showAppBar,
        enabled = true,
        assert(
            children != null || customLanes != null || sizedChildren != null),
        super(key: key);

  const StoryBoard.app({
    Key key,
    MaterialApp materialApp,
    WidgetsApp widgetsApp,
    CupertinoApp cupertinoApp,
    List<Widget> customScreens,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset,
    this.initialScale,
    this.customLanes,
    this.usePreferences = false,
    this.customAppBar,
    this.customRoutes,
    this.crossAxisCount,
    this.screenBuilder,
    this.title = _kTitle,
    this.laneBuilder,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
    this.sizedChildren,
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
    Key key,
    Widget child,
    List<Widget> customScreens,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset,
    this.customLanes,
    this.initialScale,
    this.usePreferences = false,
    this.customAppBar,
    this.customRoutes,
    this.screenBuilder,
    this.crossAxisCount,
    this.title = _kTitle,
    this.laneBuilder,
    this.sizedChildren,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
  })  : _materialApp = null,
        _widgetsApp = null,
        _cupertinoApp = child,
        children = customScreens,
        _widgets = false,
        hideAppBar = false,
        assert(child != null),
        super(key: key);

  const StoryBoard.widgets({
    Key key,
    Widget child,
    List<Widget> customScreens,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset,
    this.initialScale,
    this.customLanes,
    this.usePreferences = false,
    this.customAppBar,
    this.customRoutes,
    this.screenBuilder,
    this.crossAxisCount,
    this.title = _kTitle,
    this.laneBuilder,
    this.sizedChildren,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
  })  : _materialApp = null,
        _widgetsApp = child,
        _cupertinoApp = null,
        children = customScreens,
        _widgets = false,
        hideAppBar = false,
        assert(child != null),
        super(key: key);

  const StoryBoard.material({
    Key key,
    Widget child,
    List<Widget> customScreens,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset,
    this.initialScale,
    this.customLanes,
    this.screenBuilder,
    this.usePreferences = false,
    this.customAppBar,
    this.customRoutes,
    this.crossAxisCount,
    this.title = _kTitle,
    this.laneBuilder,
    this.sizedChildren,
    this.childrenLabel = 'Children',
    this.sizedChildrenLabel = 'Sized Children',
  })  : _materialApp = child,
        _widgetsApp = null,
        _cupertinoApp = null,
        children = customScreens,
        _widgets = false,
        hideAppBar = false,
        assert(child != null),
        super(key: key);

  /// Override the default app bar of the storyboard
  final PreferredSizeWidget customAppBar;

  /// Custom routes you want to show with test data
  final List<RouteSettings> customRoutes;

  /// Custom screens you want to show
  final List<Widget> children;

  /// Children that can have custom sizes
  final List<CustomScreen> sizedChildren;

  /// List of custom lanes
  final List<CustomLane> customLanes;

  /// You can disable this widget at any time and just return the child
  final bool enabled;

  /// Initial Offset of the canvas
  final Offset initialOffset;

  /// Initial Scale of the canvas
  final double initialScale;

  /// Size for each screen
  final Size screenSize;

  /// Use shared preferences to store the values
  final bool usePreferences;

  /// Wrap your Cupertino App with this widget
  final CupertinoApp _cupertinoApp;

  /// Wrap your Material App with this widget
  final MaterialApp _materialApp;

  /// Wrap your Widgets App with this widget
  final WidgetsApp _widgetsApp;

  /// Number of widgets to show in a row instead of maxLaneWidth
  final int crossAxisCount;

  /// Optionally hide the AppBar if used as a widget
  final bool hideAppBar;

  /// Title for AppBar
  final String title;

  /// Optionally wrap the screen building process to customize the label
  final ScreenBuilder screenBuilder;

  /// Optionally wrap the lane building process to customize the look
  final LaneBuilder laneBuilder;

  /// Label for Custom Screens or Children
  final String childrenLabel, sizedChildrenLabel;

  // /// Max lane width instead of crossAxisCount
  // final double maxLaneWidth;

  final bool _widgets;

  @override
  StoryboardController createState() => StoryboardController();
}

class StoryboardController extends State<StoryBoard> {
  FocusNode _focusNode;
  Offset _offset = Offset.zero;
  String _offsetKey = 'flutter_storyboard_offset';
  SharedPreferences _prefs;
  int _row = 0;
  double _scale = 1;
  String _scaleKey = 'flutter_storyboard_scale';
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
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateScale(widget?.initialScale ?? 0.75, true);
      updateOffset(widget?.initialOffset ?? Offset(10, -_kSpacing), true);
      if (mounted) setState(() {});
    });
    if (widget.usePreferences) {
      SharedPreferences.getInstance().then((value) {
        _prefs = value;
        final _savedScale = _prefs.getDouble(_scaleKey);
        if (_savedScale != null) {
          updateScale(_savedScale, true);
        }
        final _savedOffsetDx = _prefs.getDouble('$_offsetKey\_dx');
        final _savedOffsetDy = _prefs.getDouble('$_offsetKey\_dy');
        if (_savedOffsetDx != null && _savedOffsetDy != null) {
          updateOffset(Offset(_savedOffsetDx, _savedOffsetDy), true);
        }
      });
    }
    super.initState();
  }

  void restart() {
    _key = UniqueKey();
    if (mounted) setState(() {});
  }

  Widget get app {
    if (materialApp != null) return materialApp;
    if (widgetsApp != null) return widgetsApp;
    if (cupertinoApp != null) return cupertinoApp;
    return null;
  }

  MaterialApp get materialApp => widget?._materialApp;

  WidgetsApp get widgetsApp => widget?._widgetsApp;

  CupertinoApp get cupertinoApp => widget?._cupertinoApp;

  Widget get home {
    if (materialApp != null) return materialApp?.home;
    if (widgetsApp != null) return widgetsApp?.home;
    if (cupertinoApp != null) return cupertinoApp?.home;
    return null;
  }

  Map<String, WidgetBuilder> get routes {
    if (materialApp != null) return materialApp?.routes;
    if (widgetsApp != null) return widgetsApp?.routes;
    if (cupertinoApp != null) return cupertinoApp?.routes;
    return null;
  }

  String get initialRoute {
    if (materialApp != null) return materialApp?.initialRoute;
    if (widgetsApp != null) return widgetsApp?.initialRoute;
    if (cupertinoApp != null) return cupertinoApp?.initialRoute;
    return null;
  }

  void _handleKeyPress(RawKeyEvent key) {
    // Scale keys
    if (key.isKeyPressed(LogicalKeyboardKey.minus)) {
      updateScale(-0.02);
    }
    if (key.isKeyPressed(LogicalKeyboardKey.equal)) {
      updateScale(0.02);
    }
    // Directional Keys
    if (key.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      updateOffset(Offset(15.0, 0.0));
    }
    if (key.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      updateOffset(Offset(-15.0, 0.0));
    }
    if (key.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      updateOffset(Offset(0.0, 15.0));
    }
    if (key.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      updateOffset(Offset(0.0, -15.0));
    }
  }

  void updateOffset(Offset value, [bool force = false]) {
    if (mounted)
      setState(() {
        if (force) {
          _offset = value;
        } else {
          _offset += value;
        }
      });
    _prefs?.setDouble('$_offsetKey\_dx', _offset.dx);
    _prefs?.setDouble('$_offsetKey\_dy', _offset.dy);
  }

  void updateScale(double value, [bool force = false]) {
    if (mounted)
      setState(() {
        if (force) {
          _scale = value;
        } else {
          _scale += value;
        }
      });
    _prefs?.setDouble(_scaleKey, _scale);
  }

  Size get size {
    if (widget.screenBuilder != null) {
      return widget.screenSize;
    }
    if (widget.screenSize != null) {
      return Size(
        widget.screenSize.width,
        widget.screenSize.height + _kLabelHeight,
      );
    }
    return null;
  }

  CustomScreen _addChild(
    RouteSettings route, {
    String label,
    Widget child,
    bool customWidget = false,
    Size customSize,
  }) {
    final _size = customSize ?? widget.screenSize;
    if (widget.screenBuilder != null) {
      return CustomScreen(
        size: size,
        child: Material(
          child: widget.screenBuilder(
            context,
            route,
            _buildApp(_size, route, child, customWidget),
          ),
        ),
      );
    }
    return CustomScreen(
      size: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildApp(_size, route, child, customWidget),
          if (label != null)
            Container(
              height: _kLabelHeight,
              width: _size.width,
              child: Center(child: RoundedLabel(label)),
            ),
        ],
      ),
    );
  }

  Widget _buildApp(
    Size _size,
    RouteSettings route,
    Widget child,
    bool customWidget,
  ) {
    return Material(
      elevation: 2,
      child: SizedBox.fromSize(
        size: _size,
        child: ClipRect(
          clipper: CustomRect(Offset(0, 0)),
          child: NestedApp(
            route: route,
            child: child,
            size: _size,
            customWidget: customWidget,
            materialApp: materialApp,
            cupertinoApp: cupertinoApp,
            widgetsApp: widgetsApp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return app;
    final _theme = Theme.of(context);
    return MaterialApp(
      key: _key,
      debugShowCheckedModeBanner: false,
      themeMode: materialApp?.themeMode ?? ThemeMode.system,
      theme: materialApp?.theme ?? _theme ?? ThemeData.light(),
      darkTheme: materialApp?.darkTheme ?? _theme ?? ThemeData.dark(),
      // builder: (context, child) => MediaQueryObserver(
      //   data: MediaQuery.of(context).copyWith(size: size),
      //   child: child,
      // ),
      home: LayoutBuilder(
        builder: (context, dimens) => Scaffold(
          appBar: _buildAppBar(dimens.maxWidth <= _kCompactBreakpoint),
          body: RawKeyboardListener(
            focusNode: _focusNode,
            onKey: _handleKeyPress,
            child: GestureDetector(
              onPanUpdate: (details) {
                updateOffset(details.delta);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: OverflowBox(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget._widgets)
                        Positioned(
                          top: _offset.dy + (_scale * 10),
                          left: _offset.dx + (_scale * 10),
                          child: Transform.scale(
                            scale: _scale,
                            alignment: Alignment.topLeft,
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget?.children != null)
                                    _Lane(
                                      laneBuilder: widget.laneBuilder,
                                      title: widget?.childrenLabel ?? '',
                                      scale: _scale,
                                      size: size,
                                      children: widget.children
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
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 10.0,
                                        spreadRadius: 2.0,
                                      ),
                                    ),
                                  if (widget?.sizedChildren != null)
                                    _Lane(
                                      laneBuilder: widget.laneBuilder,
                                      title: widget?.sizedChildrenLabel ?? '',
                                      scale: _scale,
                                      size: size,
                                      children: widget.sizedChildren,
                                      crossAxisCount: widget.crossAxisCount,
                                      shadow: const BoxShadow(
                                        color: Colors.black45,
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 10.0,
                                        spreadRadius: 2.0,
                                      ),
                                    ),
                                  if (widget.customLanes != null)
                                    for (final lane in widget.customLanes)
                                      _Lane(
                                        laneBuilder: widget.laneBuilder,
                                        title: lane.title,
                                        scale: _scale,
                                        size: size,
                                        crossAxisCount: widget.crossAxisCount,
                                        children: lane.children,
                                        shadow: const BoxShadow(
                                          color: Colors.black45,
                                          offset: Offset(2.0, 2.0),
                                          blurRadius: 10.0,
                                          spreadRadius: 2.0,
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (!widget._widgets) ...[
                        Positioned(
                          top: _offset.dy + (_scale * 10),
                          left: _offset.dx + (_scale * 10),
                          child: Transform.scale(
                            scale: _scale,
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Lane(
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
                                ),
                                if (routes != const <String, WidgetBuilder>{})
                                  _Lane(
                                    title: 'Routes',
                                    scale: _scale,
                                    laneBuilder: widget.laneBuilder,
                                    size: size,
                                    crossAxisCount: widget.crossAxisCount,
                                    children: [
                                      for (var i = 0;
                                          i < routes.keys.length;
                                          i++)
                                        _addChild(
                                          RouteSettings(
                                              name: routes.keys.toList()[i]),
                                          label: routes.keys.toList()[i],
                                        ),
                                    ],
                                  ),
                                if (widget.children != null)
                                  _Lane(
                                    laneBuilder: widget.laneBuilder,
                                    title: widget?.childrenLabel ?? '',
                                    scale: _scale,
                                    size: size,
                                    children: widget.children
                                        .map((e) => _addChild(
                                              null,
                                              label: null,
                                              child: e,
                                              customWidget: true,
                                            ))
                                        .toList(),
                                    crossAxisCount: widget.crossAxisCount,
                                  ),
                                if (widget.customRoutes != null)
                                  _Lane(
                                    laneBuilder: widget.laneBuilder,
                                    title: 'Custom Routes',
                                    scale: _scale,
                                    size: size,
                                    crossAxisCount: widget.crossAxisCount,
                                    children: [
                                      for (var i = 0;
                                          i < widget.customRoutes.length;
                                          i++)
                                        _addChild(
                                          widget.customRoutes[i],
                                          label: widget.customRoutes[i].name,
                                        ),
                                    ],
                                  ),
                                if (widget.customLanes != null)
                                  for (final lane in widget.customLanes)
                                    _Lane(
                                      laneBuilder: widget.laneBuilder,
                                      title: lane.title,
                                      scale: _scale,
                                      size: size,
                                      crossAxisCount: widget.crossAxisCount,
                                      children: lane.children
                                          .map((e) => _addChild(
                                                null,
                                                label: e.label,
                                                child: e.child,
                                                customSize: e.size,
                                                customWidget: true,
                                              ))
                                          .toList(),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar([bool compact = false]) {
    const kRestartKey = 0;
    const kResetKey = 1;
    const kZoomInKey = 2;
    const kZoomOutKey = 4;
    return widget.hideAppBar
        ? null
        : widget?.customAppBar ??
            AppBar(
              title: Text(_kTitle),
              actions: compact
                  ? [
                      PopupMenuButton<int>(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: kRestartKey,
                            child: Text('Restart App'),
                          ),
                          PopupMenuItem(
                            value: kResetKey,
                            child: Text('Reset Defaults'),
                          ),
                          PopupMenuItem(
                            value: kZoomInKey,
                            child: Text('Zoom In'),
                          ),
                          PopupMenuItem(
                            value: kZoomOutKey,
                            child: Text('Zoom Out'),
                          ),
                        ],
                        onSelected: (val) {
                          if (val == kRestartKey) {
                            restart();
                          }
                          if (val == kResetKey) {
                            restore();
                          }
                          if (val == kZoomInKey) {
                            updateScale(0.01);
                          }
                          if (val == kZoomOutKey) {
                            updateScale(-0.01);
                          }
                        },
                      ),
                    ]
                  : [
                      IconButton(
                        tooltip: 'Restart App',
                        icon: Icon(Icons.refresh),
                        onPressed: restart,
                      ),
                      IconButton(
                        tooltip: 'Reset to Defaults',
                        icon: Icon(Icons.restore),
                        onPressed: restore,
                      ),
                      VerticalDivider(),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => updateScale(-0.01),
                      ),
                      InkWell(
                        child:
                            Center(child: Text('${(_scale * 100).round()}%')),
                        onTap: () =>
                            updateScale(widget?.initialScale ?? 0.75, true),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => updateScale(0.01),
                      ),
                    ],
            );
  }

  void restore() {
    updateScale(widget?.initialScale ?? 0.75, true);
    updateOffset(widget?.initialOffset ?? Offset(10, -_kSpacing), true);
  }
}
