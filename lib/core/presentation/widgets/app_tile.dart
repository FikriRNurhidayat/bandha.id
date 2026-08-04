import 'package:flutter/material.dart';

class AppTile extends StatelessWidget {
  const AppTile({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.child,
  });

  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
