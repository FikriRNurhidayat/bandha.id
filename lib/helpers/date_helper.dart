import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  static final dateFormat = DateFormat("d MMMM yyyy");
  static final simpleDateFormat = DateFormat("yyyy/MM/dd");

  static formatSimpleDate(DateTime date) {
    return simpleDateFormat.format(date);
  }

  static formatDateRange(DateTimeRange dateRange) {
    return "${dateFormat.format(dateRange.start)} - ${dateFormat.format(dateRange.end)}";
  }

  static formatDate(DateTime date) {
    return dateFormat.format(date);
  }

  static formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  static DateTime addMonths(DateTime t, int months) {
    final year = t.year + ((t.month + months - 1) ~/ 12);
    final month = (t.month + months - 1) % 12 + 1;
    final day = t.day;

    final lastDay = DateTime(year, month + 1, 0).day;
    final safeDay = day > lastDay ? lastDay : day;

    return DateTime(
      year,
      month,
      safeDay,
      t.hour,
      t.minute,
      t.second,
      t.millisecond,
      t.microsecond,
    );
  }

  static DateTime addYears(DateTime t, int years) {
    final year = t.year + years;
    final lastDay = DateTime(year, t.month + 1, 0).day;
    final safeDay = t.day > lastDay ? lastDay : t.day;

    return DateTime(
      year,
      t.month,
      safeDay,
      t.hour,
      t.minute,
      t.second,
      t.millisecond,
      t.microsecond,
    );
  }
}
