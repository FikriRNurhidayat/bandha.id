enum TimestampOption {
  yesterday(-1),
  today(0),
  tomorrow(1),
  now(null),
  specific(null),
  never(null);

  final int? offset;
  const TimestampOption(this.offset);

  DateTime? dateTime([DateTime? base]) {
    final now = base ?? DateTime.now();
    if (offset != null) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: offset!));
    }
    if (this == TimestampOption.now) return now;
    if (this == TimestampOption.never) return null;
    return null;
  }

  @override
  String toString() {
    switch (this) {
      case TimestampOption.yesterday:
        return "Yesterday";
      case TimestampOption.today:
        return "Today";
      case TimestampOption.tomorrow:
        return "Tomorrow";
      case TimestampOption.specific:
        return "Specific";
      case TimestampOption.now:
        return "Now";
      default:
        return "Never";
    }
  }
}

class Timestamp {
  final TimestampOption option;
  final DateTime? specific;

  const Timestamp(this.option, [this.specific]);

  factory Timestamp.specific(DateTime dateTime) {
    return Timestamp(TimestampOption.specific, dateTime);
  }

  DateTime? get dateTime {
    if (option == TimestampOption.specific) return specific;
    return option.dateTime();
  }

  factory Timestamp.now() {
    return Timestamp(TimestampOption.now);
  }
}
