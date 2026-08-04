import 'package:bandha/core/presentation/helpers/date_helper.dart';
import 'package:flutter/material.dart';

class AppDateTimeText extends StatelessWidget {
  final DateTime dateTime;

  const AppDateTimeText(this.dateTime, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      "${DateHelper.formatDate(dateTime)} at ${DateHelper.formatTime(TimeOfDay.fromDateTime(dateTime))}",
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall,
    );
  }
}
