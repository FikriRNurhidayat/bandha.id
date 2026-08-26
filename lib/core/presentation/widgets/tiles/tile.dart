import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  const Tile({
    super.key,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    required this.child,
  });

  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected ? theme.focusColor : theme.cardColor,
      child: InkWell(onTap: onTap, onLongPress: onLongPress, child: child),
    );
  }
}
