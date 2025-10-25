import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const MetricCard({
    required this.label,
    required this.value,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall!,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
