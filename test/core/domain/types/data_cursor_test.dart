import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("DataCursor", () {
    test("direction operators", () {
      expect(DataCursorDirection.next.operator, "<");
      expect(DataCursorDirection.previous.operator, ">");
    });

    test("holds direction and values", () {
      final c = DataCursor(
        direction: DataCursorDirection.previous,
        values: {"created_at": 1},
      );
      expect(c.direction, DataCursorDirection.previous);
      expect(c.values, {"created_at": 1});
    });
  });
}
