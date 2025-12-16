enum TimestampOption {
  yesterday(-1),
  today(0),
  tomorrow(1),
  now(null),
  specific(null),
  never(null);

  final int? dayOffset;
  const TimestampOption(this.dayOffset);

  DateTime? dateTime([DateTime? base]) {
    final now = base ?? DateTime.now();
    if (dayOffset != null) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: dayOffset!));
    }
    if (this == TimestampOption.now) return now;
    if (this == TimestampOption.never) return null;
    return null;
  }
}

class Timestamp {
  final TimestampOption option;
  final DateTime? specific;

  const Timestamp(this.option, [this.specific]);

  DateTime? get dateTime {
    if (option == TimestampOption.specific) return specific;
    return option.dateTime();
  }
}
