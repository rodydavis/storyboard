import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_storyboard/flutter_storyboard.dart';
import 'package:random_color/random_color.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoryBoard.material(
      enabled: true,
      usePreferences: true,
      screenSize: Size(400, 700),
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
        // home: HomeScreen(),
        initialRoute: '/settings',
        routes: {
          '/': (_) => HomeScreen(),
          '/settings': (_) => SettingsScreen(),
          for (var i = 0; i < 25; i++)
            '/screen_$i': (_) => _generateScreen(
                  title: Text('Screen$i'),
                  body: Container(color: RandomColor(i).randomColor()),
                ),
        },
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) {
              if (settings.name == '/about') return AboutScreen();
              return UnknownScreen();
            },
          );
        },
      ),
      customScreens: [
        for (var i = 0; i < 25; i++)
          _generateScreen(
            title: Text('Screen$i'),
            body: Container(color: RandomColor(i + 25).randomColor()),
          ),
      ],
      customRoutes: [
        RouteSettings(name: '/about'),
      ],
    );
  }
}

Widget _generateScreen({
  Text title,
  FloatingActionButton fab,
  Widget body,
}) {
  return Builder(
    builder: (context) => Scaffold(
      appBar: AppBar(title: title),
      body: body,
      floatingActionButton: fab,
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Text(_size.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SettingsScreen(),
          ));
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      backgroundColor: Colors.blue.shade300,
    );
  }
}

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      backgroundColor: Colors.purple.shade300,
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('404'),
      ),
      backgroundColor: Colors.red.shade300,
    );
  }
}
