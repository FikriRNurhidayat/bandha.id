import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  static final dateFormat = DateFormat("d MMMM yyyy");

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
}
