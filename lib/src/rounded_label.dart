import 'package:flutter/material.dart';

class RoundedLabel extends StatelessWidget {
  final String? label;

  const RoundedLabel(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
