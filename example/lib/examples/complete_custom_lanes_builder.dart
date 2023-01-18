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
      crossAxisCount: 7,
      showAppBar: true,
      laneBuilder: (context, title, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(4.0),
          color: RandomColor(title.hashCode).randomColor(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              child,
              if (title != null)
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
      childrenLabel: 'Custom Sized Children',
      sizedChildren: [
        for (var i = 0; i < 25; i++)
          CustomScreen(
            // label: 'Screen$i',
            size: Size(400, 700),
            child: _generateScreen(
              title: Text('Screen$i'),
              color: RandomColor(i).randomColor(),
            ),
          ),
      ],
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
                CustomScreen(
                  label: 'Screen$i',
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
