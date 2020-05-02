[![Buy Me A Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/rodydavis)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WSH3GVC49GNNJ)
[![storyboard](https://img.shields.io/pub/v/storyboard.svg)](https://pub.dev/packages/storyboard)

# storyboard

A Flutter Debug tool to see and test all your screens at once.

Demo: https://rodydavis.github.io/storyboard/

## Getting Started

Wrap your MaterialApp with Storyboard.

```dart
return StoryBoard(
      // enabled: true,
      // screenSize: Size(400, 700),
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

Now you can test all you screens with hot reload! You can also disable the widget at anytime by setting `enabled` to [false].