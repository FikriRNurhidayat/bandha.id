import 'package:bandha/core/types/timestamp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final base = DateTime(2026, 3, 1, 14, 45, 30);

  group("TimestampOption.dateTime", () {
    test("day offsets truncate to midnight", () {
      expect(TimestampOption.today.dateTime(base), DateTime(2026, 3, 1));
      expect(TimestampOption.yesterday.dateTime(base), DateTime(2026, 2, 28));
      expect(TimestampOption.tomorrow.dateTime(base), DateTime(2026, 3, 2));
    });

    test("now returns the base unchanged", () {
      expect(TimestampOption.now.dateTime(base), base);
    });

    test("now without base is close to the current time", () {
      final before = DateTime.now();
      final value = TimestampOption.now.dateTime()!;
      expect(value.isBefore(before), isFalse);
    });

    test("never and specific return null", () {
      expect(TimestampOption.never.dateTime(base), isNull);
      expect(TimestampOption.specific.dateTime(base), isNull);
    });

    test("toString", () {
      expect(TimestampOption.values.map((o) => o.toString()), [
        "Yesterday",
        "Today",
        "Tomorrow",
        "Now",
        "Specific",
        "Never",
      ]);
    });
  });

  group("Timestamp", () {
    test("specific returns the given date", () {
      final t = Timestamp.specific(base);
      expect(t.option, TimestampOption.specific);
      expect(t.dateTime, base);
    });

    test("specific option without a date is null", () {
      expect(const Timestamp(TimestampOption.specific).dateTime, isNull);
    });

    test("now delegates to the option", () {
      final t = Timestamp.now();
      expect(t.option, TimestampOption.now);
      expect(t.dateTime, isNotNull);
    });

    test("today ignores the specific date", () {
      final t = Timestamp(TimestampOption.today, base);
      DateTime today() {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day);
      }

      final before = today();
      final value = t.dateTime;
      expect(value, anyOf(before, today()));
    });

    test("never is null", () {
      expect(const Timestamp(TimestampOption.never).dateTime, isNull);
    });
  });
}
