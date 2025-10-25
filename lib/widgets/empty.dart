import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final IconData icon;
  final String text;

  const Empty(this.text, {super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 32,
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 128), Text(text)],
      ),
    );
  }
}
