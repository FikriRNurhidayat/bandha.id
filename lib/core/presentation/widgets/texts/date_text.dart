import 'package:flutter/material.dart';

class DateText extends StatelessWidget {
  const DateText(this.dateTime, {super.key, this.style});

  final DateTime dateTime;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final i18n = MaterialLocalizations.of(context);
    return Text(i18n.formatShortDate(dateTime), style: style);
  }
}
