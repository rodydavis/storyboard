part of storyboard;

class CustomLane {
  final String title;
  final List<CustomScreen> children;

  CustomLane({
    required this.title,
    required this.children,
  });
}

class CustomScreen {
  final String? label;
  final Size? size;
  final Widget child;
  final DeviceInfo? cupertinoDevice;
  final DeviceInfo? androidDevice;
  final Orientation? orientation;

  CustomScreen({
    required this.size,
    required this.child,
    this.label,
    this.androidDevice,
    this.cupertinoDevice,
    this.orientation = Orientation.portrait,
  });

  CustomScreen copyWith({
    String? label,
    Size? size,
    Widget? child,
    DeviceInfo? cupertinoDevice,
    DeviceInfo? androidDevice,
    Orientation? orientation,
  }) {
    return CustomScreen(
      label: label ?? this.label,
      size: size ?? this.size,
      child: child ?? this.child,
      cupertinoDevice: cupertinoDevice ?? this.cupertinoDevice,
      androidDevice: androidDevice ?? this.androidDevice,
      orientation: orientation ?? this.orientation,
    );
  }
}

typedef LaneBuilder = Widget Function(
  BuildContext context,
  String? title,
  Widget child,
);

class _Lane extends StatelessWidget {
  const _Lane({
    Key? key,
    required this.children,
    required this.crossAxisCount,
    required this.scale,
    required this.androidDevice,
    required this.cupertinoDevice,
    this.title,
    this.itemBuilder,
    this.laneBuilder,
    this.size,
    this.shadow,
    this.orientation = Orientation.portrait,
  }) : super(key: key);

  final List<CustomScreen> children;
  final int? crossAxisCount;
  final double scale;
  final DeviceInfo? cupertinoDevice;
  final DeviceInfo? androidDevice;
  final Orientation? orientation;
  final Widget Function(BuildContext, Widget)? itemBuilder;
  final LaneBuilder? laneBuilder;
  final String? title;
  final Size? size;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    List<CustomScreen> _children = [];
    for (final child in children) {
      if (itemBuilder != null) {
        _children
            .add(child.copyWith(child: itemBuilder!(context, child.child)));
      } else {
        _children.add(child);
      }
    }
    int _itemsPerRow;
    int _rows;
    if (crossAxisCount != null) {
      _rows = (_children.length / crossAxisCount!).ceil();
      _itemsPerRow = crossAxisCount!;
    } else {
      _rows = 1;
      _itemsPerRow = _children.length;
    }
    Widget _child;
    _child = buildWrapLane(_rows, _children, _itemsPerRow, context);
    if (laneBuilder != null) {
      return laneBuilder!(context, title, _child);
    }
    return _child;
  }

  Widget buildWrapLane(int _rows, List<CustomScreen> _children,
      int _itemsPerRow, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(_kSpacing / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _rows; i++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _children
                  .skip(i * _itemsPerRow)
                  .take(_itemsPerRow)
                  .toList()
                  .map((e) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(_kSpacing / 2),
                      child: _buildChild(context, e),
                    ),
                    if (e.label != null)
                      SizedBox(
                        height: _kLabelHeight,
                        child: Center(child: RoundedLabel(e.label!)),
                      ),
                  ],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildChild(BuildContext context, CustomScreen e) {
    return Container(
      decoration: shadow == null ? null : BoxDecoration(boxShadow: [shadow!]),
      child: MediaQueryObserver(
        data: MediaQuery.of(context).copyWith(size: size),
        child: Builder(
          builder: (context) {
            Widget _child = e.child;
            if (itemBuilder != null) {
              _child = itemBuilder!(context, _child);
            }
            DeviceInfo? _ios = e.cupertinoDevice ?? cupertinoDevice;
            DeviceInfo? _android = e.androidDevice ?? androidDevice;
            Orientation _orientation =
                e.orientation ?? orientation ?? Orientation.portrait;
            if (_ios != null) {
              return DeviceFrame(
                orientation: _orientation,
                device: _ios,
                screen: VirtualKeyboard(
                  isEnabled: true,
                  child: _child,
                ),
              );
            }
            if (_android != null) {
              return DeviceFrame(
                orientation: _orientation,
                device: _android,
                screen: VirtualKeyboard(
                  isEnabled: true,
                  child: _child,
                ),
              );
            }
            return SizedBox.fromSize(
              size: e.size,
              child: _child,
            );
          },
        ),
      ),
    );
  }
}
