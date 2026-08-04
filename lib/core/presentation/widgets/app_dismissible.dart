import 'package:flutter/material.dart';

class AppDismissible extends StatelessWidget {
  const AppDismissible({
    super.key,
    required this.child,
    required this.dismissible,
    required this.confirmDismiss,
  });

  final Widget child;
  final bool dismissible;
  final ConfirmDismissCallback confirmDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: key ?? UniqueKey(),
      direction: dismissible
          ? DismissDirection.horizontal
          : DismissDirection.none,
      confirmDismiss: confirmDismiss,
      background: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      secondaryBackground: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: child,
    );
  }
}
