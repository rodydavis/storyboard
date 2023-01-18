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
    return StoryBoard(
      showAppBar: true,
      sizedChildren: [
        for (var i = 4; i < 20; i++)
          CustomScreen(
            size: Size(i * 50.0, i * 100.0),
            child: _generateScreen(
              title: Text('Screen$i'),
              color: RandomColor(i).randomColor(),
            ),
          ),
      ],
      children: [
        for (var i = 4; i < 20; i++)
          SizedBox.fromSize(
            size: Size(i * 50.0, i * 100.0),
            child: _generateScreen(
              title: Text('Screen$i'),
              color: RandomColor(i).randomColor(),
            ),
          ),
      ],
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
