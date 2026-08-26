import 'package:flutter/material.dart';

class TimeText extends StatelessWidget {
  const TimeText(this.timeOfDay, {super.key, this.style});

  final TimeOfDay timeOfDay;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final i18n = MaterialLocalizations.of(context);
    return Text(i18n.formatTimeOfDay(timeOfDay), style: style);
  }
}
