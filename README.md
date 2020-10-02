[![Buy Me A Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/rodydavis)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WSH3GVC49GNNJ)
[![flutter_storyboard](https://img.shields.io/pub/v/flutter_storyboard.svg)](https://pub.dev/packages/flutter_storyboard)

# storyboard

A Flutter Debug tool to see and test all your screens at once.

Demo: https://rodydavis.github.io/storyboard/

![screenshot](https://github.com/rodydavis/storyboard/blob/master/doc/screenshot.png?raw=true)

## Examples

[Custom Lane Builder](https://github.com/rodydavis/storyboard/blob/master/example/lib/examples/custom_lane_builder.dart)

[Dynamic Screen Sizes](https://github.com/rodydavis/storyboard/blob/master/example/lib/examples/dynamic_screen_sizes.dart)

[Material App Example](https://github.com/rodydavis/storyboard/blob/master/example/lib/examples/material_app_example.dart)

[Widget Example](https://github.com/rodydavis/storyboard/blob/master/example/lib/examples/widget_example.dart)

[Multiple Custom Lanes Example](https://github.com/rodydavis/storyboard/blob/master/example/lib/examples/complete_custom_lanes_builder.dart)

## Getting Started

Wrap your MaterialApp with Storyboard.

```dart
return StoryBoard.material(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Storyboard Example',
        theme: ThemeData.light().copyWith(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData.dark().copyWith(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        themeMode: ThemeMode.light,
        home: HomeScreen(),
        routes: {
          '/home': (_) => HomeScreen(),
          '/about': (_) => AboutScreen(),
          '/settings': (_) => SettingsScreen(),
        },
      ),
    );
```

Wrap your WidgetsApp with Storyboard.widgets().
Wrap your CupertinoApp with Storyboard.cupertino().

## Custom Routes and Widgets

You can add any number of custom widgets to the canvas, including custom routes. You can add dummy data to the constructors here as it will render all default values.

```dart
customScreens: [
  SettingsScreen(),
  AboutScreen(),
  CustomWidget(title: 'Dummy Data'),
],
customRoutes: [
  RouteSettings(name: '/about'),
],
```

## Misc

Now you can test all your screens with a hot reload! You can also disable the widget at any time by setting `enabled` to false. You will need to do a hot restart after you change this value.
