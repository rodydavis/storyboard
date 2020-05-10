library storyboard;

import 'package:device_preview/device_preview.dart' as preview;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/custom_rect_clipper.dart';
import 'src/nested_app.dart';
import 'src/rounded_label.dart';

const _kSpacing = 40.0;
const _kLabelHeight = 65.0;
const _kTitle = 'Storyboard';

typedef LaneBuilder = Widget Function(
    BuildContext context, String title, Widget child);
typedef ScreenBuilder = Widget Function(
    BuildContext context, RouteSettings route, Widget child);

class StoryBoard extends StatefulWidget {
  const StoryBoard({
    Key key,
    @required this.children,
    bool showAppBar = false,
    Size childSize,
    this.initialOffset,
    this.customLanes,
    this.initialScale,
    this.usePreferences = false,
    this.customAppBar,
    this.crossAxisCount,
    this.title = _kTitle,
    this.useDevicePreview = false,
    this.laneBuilder,
  })  : _materialApp = null,
        _widgetsApp = null,
        _cupertinoApp = null,
        _widgets = true,
        screenBuilder = null,
        screenSize = childSize,
        customRoutes = null,
        hideAppBar = !showAppBar,
        enabled = true,
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
    this.useDevicePreview = false,
    this.laneBuilder,
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
    this.useDevicePreview = false,
    this.laneBuilder,
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
    this.useDevicePreview = false,
    this.laneBuilder,
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
    this.useDevicePreview = false,
    this.laneBuilder,
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

  // /// Max lane width instead of crossAxisCount
  // final double maxLaneWidth;

  final bool useDevicePreview;

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
  preview.DevicePreviewData _devicePreviewData;
  String _scaleKey = 'flutter_storyboard_scale';

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
    _devicePreviewData = preview.DevicePreviewData(
      isFrameVisible: true,
      deviceIndex: 0,
      orientation: Orientation.portrait,
    );
    super.initState();
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
    if (widget.useDevicePreview) {
      final data = _devicePreviewData;
      final device = preview.Devices.all[data.deviceIndex];
      final isRotated = data.orientation == Orientation.landscape;
      final screenSize = isRotated || device.portrait == null
          ? device.landscape.size
          : device.portrait.size;
      return screenSize;
    }
    if (widget.screenSize != null) {
      return Size(
        widget.screenSize.width,
        widget.screenSize.height + _kLabelHeight,
      );
    }
    return null;
  }

  Widget _addChild(
    RouteSettings route, {
    String label,
    Widget child,
    bool customWidget = false,
  }) {
    if (widget.screenBuilder != null) {
      return Material(
        child: widget.screenBuilder(
          context,
          route,
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000),
                  offset: Offset(20.0, 10.0),
                  blurRadius: 20.0,
                  spreadRadius: 40.0,
                )
              ],
            ),
            child: SizedBox.fromSize(
              size: size,
              child: _nestedApp(route, child, size, customWidget),
            ),
          ),
        ),
      );
    }
    if (widget.useDevicePreview) {
      final data = _devicePreviewData;
      final device = preview.Devices.all[data.deviceIndex];
      final isRotated = data.orientation == Orientation.landscape;
      final screenSize = isRotated || device.portrait == null
          ? device.landscape.size
          : device.portrait.size;
      if (data.isFrameVisible) {
        return preview.DevicePreview(
          data: _devicePreviewData,
          isToolBarVisible: false,
          builder: (context) => _nestedApp(
            route,
            child,
            screenSize,
            customWidget,
          ),
        );
      }
      return SizedBox.fromSize(
        size: screenSize,
        child: _nestedApp(route, child, size, customWidget),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4,
          child: SizedBox.fromSize(
            size: size,
            child: _nestedApp(route, child, size, customWidget),
          ),
        ),
        if (label != null)
          Container(
            height: _kLabelHeight,
            width: size.width,
            child: Center(child: RoundedLabel(label)),
          ),
      ],
    );
  }

  ClipRect _nestedApp(
      RouteSettings route, Widget child, Size _size, bool customWidget) {
    return ClipRect(
      clipper: CustomRect(Offset(0, 0)),
      child: NestedApp(
        route: route,
        child: child,
        devicePreviewData: _devicePreviewData,
        useDevicePreview: widget.useDevicePreview,
        size: _size,
        customWidget: customWidget,
        materialApp: materialApp,
        cupertinoApp: cupertinoApp,
        widgetsApp: widgetsApp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return app;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: materialApp?.themeMode ?? ThemeMode.system,
      theme: materialApp?.theme ?? ThemeData.light(),
      darkTheme: materialApp?.darkTheme ?? ThemeData.dark(),
      home: Scaffold(
        appBar: _buildAppBar(),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Lane(
                                laneBuilder: widget.laneBuilder,
                                title: 'Children',
                                scale: _scale,
                                size: size,
                                children: widget.children,
                                crossAxisCount: widget.crossAxisCount,
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
                                  ),
                            ],
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
                                    for (var i = 0; i < routes.keys.length; i++)
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
                                  title: 'Custom Screens',
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
                                              label: null,
                                              child: e,
                                              customWidget: true,
                                            ))
                                        .toList(),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // if (widget.useDevicePreview)
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   left: 0,
                    //   child: DevicePreviewVerticalToolBar(),
                    // )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return widget.hideAppBar
        ? null
        : widget?.customAppBar ??
            AppBar(
              title: Text(_kTitle),
              actions: [
                IconButton(
                  icon: Icon(Icons.restore),
                  onPressed: () {
                    updateScale(widget?.initialScale ?? 0.75, true);
                    updateOffset(
                        widget?.initialOffset ?? Offset(10, -_kSpacing), true);
                  },
                ),
                VerticalDivider(),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => updateScale(-0.01),
                ),
                InkWell(
                  child: Center(child: Text('${(_scale * 100).round()}%')),
                  onTap: () => updateScale(0.75, true),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => updateScale(0.01),
                ),
              ],
            );
  }
}

class CustomLane {
  final String title;
  final List<Widget> children;

  CustomLane({
    @required this.title,
    @required this.children,
  });
}

class _Lane extends StatelessWidget {
  const _Lane({
    Key key,
    @required this.children,
    @required this.crossAxisCount,
    this.itemBuilder,
    this.laneBuilder,
    @required this.scale,
    this.title,
    this.size,
  }) : super(key: key);

  final List<Widget> children;
  final int crossAxisCount;
  final Size size;
  final double scale;
  final LaneBuilder laneBuilder;
  final String title;
  final Widget Function(BuildContext, Widget) itemBuilder;

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = [];
    for (final child in children) {
      if (itemBuilder != null) {
        _children.add(itemBuilder(context, child));
      } else {
        _children.add(child);
      }
    }
    int _itemsPerRow;
    int _rows;
    if (crossAxisCount != null) {
      _rows = (_children.length / crossAxisCount).ceil();
      _itemsPerRow = crossAxisCount;
    } else {
      _rows = 1;
      _itemsPerRow = _children.length;
    }
    Widget _child;
    if (size == null) {
      _child = buildWrapLane(_rows, _children, _itemsPerRow, context);
    } else {
      final _gridSize = Size(
        (_kSpacing + size.width) * _itemsPerRow,
        (_kSpacing + size.height) * _rows,
      );
      _child = buildGridLane(_gridSize, _children, context);
    }
    if (laneBuilder != null) {
      return laneBuilder(context, title, _child);
    }
    return _child;
  }

  Widget buildGridLane(
      Size gridSize, List<Widget> _children, BuildContext context) {
    return Container(
      margin: EdgeInsets.all(_kSpacing / 2),
      child: SizedBox.fromSize(
        size: gridSize,
        child: GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount ?? children.length,
            crossAxisSpacing: _kSpacing,
            mainAxisSpacing: _kSpacing,
            childAspectRatio: size.width / size.height,
          ),
          children: _children.map((e) {
            Widget _child = SizedBox.fromSize(size: size, child: e);
            if (itemBuilder != null) {
              _child = itemBuilder(context, _child);
            }
            return Center(child: _child);
          }).toList(),
        ),
      ),
    );
  }

  Widget buildWrapLane(int _rows, List<Widget> _children, int _itemsPerRow,
      BuildContext context) {
    return Container(
      margin: EdgeInsets.all(_kSpacing / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _rows; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _children
                  .skip(i * _itemsPerRow)
                  .take(_itemsPerRow)
                  .toList()
                  .map((e) {
                Widget _child = e;
                if (itemBuilder != null) {
                  _child = itemBuilder(context, _child);
                }
                return Container(
                  padding: const EdgeInsets.all(_kSpacing / 2),
                  width: size?.width,
                  height: size?.height,
                  child: Center(child: _child),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
