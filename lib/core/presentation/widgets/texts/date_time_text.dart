import 'package:flutter/material.dart';

class DateTimeText extends StatelessWidget {
  const DateTimeText(this.dateTime, {super.key, this.style});

  final DateTime dateTime;
  final TextStyle? style;

  TimeOfDay get timeOfDay => TimeOfDay.fromDateTime(dateTime);

  @override
  Widget build(BuildContext context) {
    final i18n = MaterialLocalizations.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: i18n.formatShortDate(dateTime), style: style),
          TextSpan(text: " at ", style: style),
          TextSpan(text: i18n.formatTimeOfDay(timeOfDay), style: style),
        ],
      ),
    );
  }
}
