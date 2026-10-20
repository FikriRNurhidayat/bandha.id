import 'package:bandha/core/types/date_option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("DateOption labels", () {
    expect(DateOption.values.map((o) => o.label), [
      "Today",
      "Yesterday",
      "1 Week",
      "1 Month",
      "Specific",
    ]);
  });
}
