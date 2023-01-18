import 'package:flutter/material.dart';
import 'package:flutter_storyboard/flutter_storyboard.dart';
import 'package:random_color/random_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StoryBoard.material(
      enabled: true,
      crossAxisCount: 7,
      cupertinoDevice: Devices.ios.iPhone13,
      screenSize: const Size(400, 700),
      customScreens: [
        for (var i = 0; i < 25; i++)
          _generateScreen(
            title: Text('Screen$i'),
            color: RandomColor(i + 25).randomColor(),
          ),
      ],
      customRoutes: const [
        RouteSettings(name: '/about'),
        RouteSettings(name: '/counter'),
        RouteSettings(name: '/screen_2'),
        RouteSettings(name: '/screen_5'),
        RouteSettings(
          name: '/screen_8',
          arguments: <String, dynamic>{'id': 1234},
        ),
      ],
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
          '/': (_) => const HomeScreen(),
          '/counter': (_) => const CounterScreen(),
          '/settings': (_) => SettingsScreen(),
          for (var i = 0; i < 25; i++)
            '/screen_$i': (_) => _generateScreen(
                  title: Text('Screen$i'),
                  color: RandomColor(i).randomColor(),
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
    );
  }
}

Widget _generateScreen({
  Text? title,
  FloatingActionButton? fab,
  Color? color,
}) {
  return Builder(
    builder: (context) {
      final route = ModalRoute.of(context);
      final settings = route?.settings;
      final args = settings?.arguments as Map<String, dynamic>?;
      return Scaffold(
        appBar: AppBar(title: title),
        backgroundColor: color,
        body: args == null ? null : Center(child: Text(args.toString())),
        floatingActionButton: fab,
      );
    },
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Text(_size.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.info),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SettingsScreen(),
          ));
        },
      ),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Example'),
      ),
      body: Center(
        child: Text('Counter: $_counter'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          if (mounted)
            setState(() {
              _counter++;
            });
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
        title: const Text('Settings'),
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
        title: const Text('About'),
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
        title: const Text('404'),
      ),
      backgroundColor: Colors.red.shade300,
    );
  }
}
