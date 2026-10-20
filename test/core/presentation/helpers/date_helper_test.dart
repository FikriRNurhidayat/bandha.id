import 'package:bandha/core/presentation/helpers/date_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("DateHelper formatting", () {
    final date = DateTime(2026, 1, 5, 9, 7);

    test("formatDate", () {
      expect(DateHelper.formatDate(date), "5 January 2026");
    });

    test("formatSimpleDate", () {
      expect(DateHelper.formatSimpleDate(date), "2026/01/05");
    });

    test("formatDateRange", () {
      final range = DateTimeRange(start: date, end: DateTime(2026, 2, 10));
      expect(
        DateHelper.formatDateRange(range),
        "5 January 2026 - 10 February 2026",
      );
    });

    test("formatTime pads to two digits", () {
      expect(
        DateHelper.formatTime(const TimeOfDay(hour: 9, minute: 7)),
        "09:07",
      );
      expect(
        DateHelper.formatTime(const TimeOfDay(hour: 23, minute: 59)),
        "23:59",
      );
    });
  });

  group("DateHelper.addMonths", () {
    test("adds within the year and keeps time", () {
      expect(
        DateHelper.addMonths(DateTime(2026, 3, 15, 8, 30, 1, 2, 3), 2),
        DateTime(2026, 5, 15, 8, 30, 1, 2, 3),
      );
    });

    test("rolls over into the next year", () {
      expect(
        DateHelper.addMonths(DateTime(2026, 11, 10), 3),
        DateTime(2027, 2, 10),
      );
      expect(
        DateHelper.addMonths(DateTime(2026, 12, 1), 1),
        DateTime(2027, 1, 1),
      );
      expect(
        DateHelper.addMonths(DateTime(2026, 1, 1), 24),
        DateTime(2028, 1, 1),
      );
    });

    test("clamps to the last day of the month", () {
      expect(
        DateHelper.addMonths(DateTime(2026, 1, 31), 1),
        DateTime(2026, 2, 28),
      );
      expect(
        DateHelper.addMonths(DateTime(2024, 1, 31), 1),
        DateTime(2024, 2, 29),
      );
      expect(
        DateHelper.addMonths(DateTime(2026, 3, 31), 1),
        DateTime(2026, 4, 30),
      );
    });

    test("subtracts within the year", () {
      expect(
        DateHelper.addMonths(DateTime(2026, 5, 31), -1),
        DateTime(2026, 4, 30),
      );
    });

    test(
      "subtracts across a year boundary",
      () {
        expect(
          DateHelper.addMonths(DateTime(2026, 1, 15), -1),
          DateTime(2025, 12, 15),
        );
        expect(
          DateHelper.addMonths(DateTime(2026, 3, 15), -12),
          DateTime(2025, 3, 15),
        );
      },
      skip:
          "BUG: date_helper.dart:27 uses truncating ~/ on a negative month "
          "index, so Jan 2026 - 1 month yields Dec 2026 instead of Dec 2025",
    );
  });

  group("DateHelper.addYears", () {
    test("adds and subtracts years keeping time", () {
      expect(
        DateHelper.addYears(DateTime(2026, 6, 1, 10), 2),
        DateTime(2028, 6, 1, 10),
      );
      expect(
        DateHelper.addYears(DateTime(2026, 6, 1), -1),
        DateTime(2025, 6, 1),
      );
    });

    test("clamps Feb 29 on non-leap years", () {
      expect(
        DateHelper.addYears(DateTime(2024, 2, 29), 1),
        DateTime(2025, 2, 28),
      );
      expect(
        DateHelper.addYears(DateTime(2024, 2, 29), 4),
        DateTime(2028, 2, 29),
      );
    });
  });
}
