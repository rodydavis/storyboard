import 'package:flutter/material.dart';
import 'package:flutter_storyboard/flutter_storyboard.dart';
import 'package:random_color/random_color.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoryBoard(
      usePreferences: true,
      crossAxisCount: 7,
      showAppBar: true,
      laneBuilder: (context, title, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(4.0),
          color: RandomColor(title.hashCode).randomColor(),
          child: Stack(
            overflow: Overflow.visible,
            children: [
              child,
              Positioned(
                left: -50,
                top: 350,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      children: [
        for (var i = 0; i < 25; i++)
          SizedBox.fromSize(
            size: Size(400, 700),
            child: _generateScreen(
              title: Text('Screen$i'),
              color: RandomColor(i).randomColor(),
            ),
          ),
      ],
      customLanes: [
        for (var i = 0; i < 25; i++)
          CustomLane(
            title: i.toString(),
            children: [
              for (var i = 0; i < 25; i++)
                SizedBox.fromSize(
                  size: Size(400, 700),
                  child: _generateScreen(
                    title: Text('Screen$i'),
                    color: RandomColor(i).randomColor(),
                  ),
                ),
            ],
          )
      ],
    );
  }
}

Widget _generateScreen({
  Text title,
  FloatingActionButton fab,
  Color color,
}) {
  return Builder(
    builder: (context) {
      final Map<String, dynamic> args =
          ModalRoute.of(context).settings.arguments;
      return Scaffold(
        appBar: AppBar(title: title),
        backgroundColor: color,
        body: args == null ? null : Center(child: Text(args.toString())),
        floatingActionButton: fab,
      );
    },
  );
}
