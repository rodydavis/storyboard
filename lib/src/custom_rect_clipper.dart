import 'package:flutter/material.dart';

class CustomRect extends CustomClipper<Rect> {
  final Offset offset;

  CustomRect(this.offset);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(CustomRect oldClipper) {
    return true;
  }
}
