import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/core_helpers.dart';
import '../../../support/fakes.dart';

class QueryThings extends QueryEntities<Thing> {
  QueryThings(super.repository);
}

void main() {
  group("QueryEntities", () {
    test("builds a DataQuery with defaults", () async {
      final repo = InMemoryRepository<Thing>(seed: [Thing("a"), Thing("b")]);
      final result = await QueryThings(repo).execute();
      expect(result.map((t) => t.id), unorderedEquals(["a", "b"]));
      expect(repo.lastQuery!.filter, isEmpty);
      expect(repo.lastQuery!.cursor, isNull);
      expect(repo.lastQuery!.size, 25);
    });

    test("forwards filter, cursor and size", () async {
      final repo = InMemoryRepository<Thing>(seed: [Thing("a"), Thing("b")]);
      final cursor = DataCursor(
        direction: DataCursorDirection.next,
        values: {"id": "x"},
      );
      final result = await QueryThings(
        repo,
      ).execute(filter: {"id_eq": "b"}, cursor: cursor, size: 3);
      expect(result.map((t) => t.id), ["b"]);
      expect(repo.lastQuery!.filter, {"id_eq": "b"});
      expect(repo.lastQuery!.cursor, same(cursor));
      expect(repo.lastQuery!.size, 3);
    });
  });
}
