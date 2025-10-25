import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final IconData? icon;
  final String text;

  const Empty(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        spacing: 16,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon, size: 64),
          if (icon == null)
            Text(
              "It's empty here",
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          Text(
            text,
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
