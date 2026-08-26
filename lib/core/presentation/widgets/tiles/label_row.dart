import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:flutter/material.dart';

class LabelRow extends StatelessWidget {
  final Iterable<Label> labels;

  const LabelRow(this.labels, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: 8,
      children: [
        ...labels
            .take(2)
            .map(
              (label) => Text(
                label.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
        if (labels.length > 2)
          Icon(Icons.more_horiz, size: 8, color: theme.colorScheme.primary),
      ],
    );
  }
}
