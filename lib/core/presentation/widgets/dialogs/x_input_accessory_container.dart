import 'package:flutter/material.dart';

class XInputAccessoryContainer extends StatelessWidget {
  final Widget child;

  const XInputAccessoryContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.all(16), child: child);
  }
}
