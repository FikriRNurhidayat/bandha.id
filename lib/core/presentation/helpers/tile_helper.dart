import 'package:flutter/material.dart';

Widget tileBuilder(
  BuildContext context, {
  GestureTapCallback? onTap,
  GestureLongPressCallback? onLongPress,
  required Widget child,
}) {
  final theme = Theme.of(context);
  return Material(
    color: theme.cardColor,
    child: InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(padding: EdgeInsets.all(16), child: child),
    ),
  );
}

Widget dismissibleBuilder(
  BuildContext context, {
  required dynamic key,
  required Widget child,
  required bool dismissable,
  required ConfirmDismissCallback confirmDismiss,
}) {
  final theme = Theme.of(context);
  return Dismissible(
    key: Key(key),
    background: Container(
      color: theme.colorScheme.surfaceContainer,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16),
    ),
    secondaryBackground: Container(
      color: theme.colorScheme.surfaceContainer,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16),
    ),
    direction: !dismissable
        ? DismissDirection.none
        : DismissDirection.horizontal,
    confirmDismiss: confirmDismiss,
    child: child,
  );
}
