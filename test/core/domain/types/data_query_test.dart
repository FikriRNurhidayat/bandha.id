import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("DataQuery", () {
    test("defaults to empty filter and size 25", () {
      final q = DataQuery();
      expect(q.filter, isEmpty);
      expect(q.cursor, isNull);
      expect(q.size, 25);
    });

    test("default filters are not shared between instances", () {
      final a = DataQuery();
      a.filter["x"] = 1;
      expect(DataQuery().filter, isEmpty);
    });

    test("keeps given values", () {
      final cursor = DataCursor(
        direction: DataCursorDirection.next,
        values: {"id": "a"},
      );
      final q = DataQuery(filter: {"id_eq": "a"}, cursor: cursor, size: 5);
      expect(q.filter, {"id_eq": "a"});
      expect(q.cursor, same(cursor));
      expect(q.size, 5);
    });
  });
}
