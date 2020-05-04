library storyboard;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/custom_rect_clipper.dart';
import 'src/nested_app.dart';
import 'src/rounded_label.dart';

const _kSpacing = 40.0;

class StoryBoard extends StatefulWidget {
  const StoryBoard({
    Key key,
    MaterialApp materialApp,
    WidgetsApp widgetsApp,
    CupertinoApp cupertinoApp,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset,
    this.initialScale,
    this.usePreferences = false,
    this.customAppBar,
    this.customRoutes,
    this.customScreens,
  })  : _materialApp = materialApp,
        _widgetsApp = widgetsApp,
        _cupertinoApp = cupertinoApp,
        assert(
            materialApp != null || widgetsApp != null || cupertinoApp != null),
        super(key: key);

  const StoryBoard.cupertino({
    Key key,
    Widget child,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset,
    this.initialScale,
    this.usePreferences = false,
    this.customAppBar,
    this.customRoutes,
    this.customScreens,
  })  : _materialApp = null,
        _widgetsApp = null,
        _cupertinoApp = child,
        assert(child != null),
        super(key: key);

  const StoryBoard.widgets({
    Key key,
    Widget child,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset,
    this.initialScale,
    this.usePreferences = false,
    this.customAppBar,
    this.customRoutes,
    this.customScreens,
  })  : _materialApp = null,
        _widgetsApp = child,
        _cupertinoApp = null,
        assert(child != null),
        super(key: key);

  const StoryBoard.material({
    Key key,
    Widget child,
    this.enabled = true,
    this.screenSize = const Size(400, 700),
    this.initialOffset,
    this.initialScale,
    this.usePreferences = false,
    this.customAppBar,
    this.customRoutes,
    this.customScreens,
  })  : _materialApp = child,
        _widgetsApp = null,
        _cupertinoApp = null,
        assert(child != null),
        super(key: key);

  /// Override the default app bar of the storyboard
  final AppBar customAppBar;

  /// Custom routes you want to show with test data
  final List<RouteSettings> customRoutes;

  /// Custom screens you want to show
  final List<Widget> customScreens;

  /// You can disable this widget at any time and just return the child
  final bool enabled;

  /// Initial Offset of the canvas
  final Offset initialOffset;

  /// Initial Scale of the canvas
  final double initialScale;

  /// Size for each screen
  final Size screenSize;

  final bool usePreferences;

  /// Wrap your Cupertino App with this widget
  final CupertinoApp _cupertinoApp;

  /// Wrap your Material App with this widget
  final MaterialApp _materialApp;

  /// Wrap your Widgets App with this widget
  final WidgetsApp _widgetsApp;

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
      updateOffset(widget?.initialOffset ?? Offset(10, -40), true);
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

  Offset _getOffset(Size _size, int row, [int i = 1]) {
    return Offset((_size.width + _kSpacing) * i,
        (((_size.height + _kSpacing + 40) * row)));
  }

  void _handleKeyPress(RawKeyEvent key) {
    // Scale keys
    if (key.isKeyPressed(LogicalKeyboardKey.minus)) {
      updateScale(_scale - 0.02);
    }
    if (key.isKeyPressed(LogicalKeyboardKey.equal)) {
      updateScale(_scale + 0.02);
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

  List<Widget> _addRow(int place, List<Widget> Function(int) children) =>
      children(_row++);

  Positioned _addChild(
    RouteSettings route, {
    Offset offset = Offset.zero,
    String label,
    Widget child,
    bool customWidget = false,
  }) {
    final _top = _offset.dy + (_scale * offset.dy);
    final _left = _offset.dx + (_scale * offset.dx);
    final _size = widget.screenSize;
    return Positioned(
      top: _top,
      left: _left,
      child: Transform.scale(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.fromSize(
              size: _size,
              child: Material(
                elevation: 4,
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
            ),
            if (label != null) Center(child: RoundedLabel(label)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _size = widget.screenSize;
    _row = 0;
    if (!widget.enabled) return app;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: materialApp?.themeMode ?? ThemeMode.system,
      theme: materialApp?.theme ?? ThemeData.light(),
      darkTheme: materialApp?.darkTheme ?? ThemeData.dark(),
      home: Scaffold(
        appBar: widget?.customAppBar ??
            AppBar(
              title: Text('Storyboard'),
              actions: [
                IconButton(
                  icon: Icon(Icons.restore),
                  onPressed: () {
                    updateScale(0.75, true);
                    updateOffset(Offset(10, -40), true);
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
            ),
        body: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: _handleKeyPress,
          child: GestureDetector(
            onPanUpdate: (panDetials) {
              updateOffset(panDetials.delta);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: OverflowBox(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ..._addRow(
                        0,
                        (row) => [
                              if (home != null)
                                _addChild(
                                  null,
                                  offset: Offset(0, 10),
                                  label: 'Home',
                                  child: home,
                                ),
                              if (initialRoute != null)
                                _addChild(
                                  RouteSettings(name: initialRoute),
                                  offset: Offset(
                                      home != null
                                          ? ((_size.width + _kSpacing) * 1)
                                          : 0,
                                      10),
                                  label: 'Initial Route',
                                ),
                            ]),
                    if (routes != const <String, WidgetBuilder>{})
                      ..._addRow(
                          1,
                          (row) => [
                                for (var i = 0; i < routes.keys.length; i++)
                                  _addChild(
                                    RouteSettings(
                                        name: routes.keys.toList()[i]),
                                    offset: _getOffset(_size, row, i),
                                    label: routes.keys.toList()[i],
                                  ),
                              ]),
                    if (widget.customScreens != null)
                      ..._addRow(
                          2,
                          (row) => [
                                for (var i = 0;
                                    i < widget.customScreens.length;
                                    i++)
                                  _addChild(
                                    null,
                                    offset: _getOffset(_size, row, i),
                                    label: widget.customScreens[i].toString(),
                                    child: widget.customScreens[i],
                                    customWidget: true,
                                  ),
                              ]),
                    if (widget.customRoutes != null)
                      ..._addRow(
                          3,
                          (row) => [
                                for (var i = 0;
                                    i < widget.customRoutes.length;
                                    i++)
                                  _addChild(
                                    widget.customRoutes[i],
                                    offset: _getOffset(_size, row, i),
                                    label: widget.customRoutes[i].name,
                                  ),
                              ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
