import 'package:bandha/core/domain/types/data_cursor.dart';
import 'package:bandha/modules/assets/application/use_cases/query_assets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  group("QueryAssets", () {
    test("forwards filter, cursor and size to the repository", () async {
      final a = makeAsset(id: "a");
      final repository = FakeAssetRepository(
        seed: [
          a,
          makeAsset(id: "b"),
        ],
      );
      final cursor = DataCursor(
        direction: DataCursorDirection.next,
        values: {"id": "z"},
      );

      final result = await QueryAssets(
        assetRepository: repository,
      ).execute(filter: {"id_eq": "a"}, cursor: cursor, size: 10);

      expect(result.toList(), [a]);
      expect(repository.lastQuery!.filter, {"id_eq": "a"});
      expect(repository.lastQuery!.cursor, same(cursor));
      expect(repository.lastQuery!.size, 10);
    });

    test("defaults to an empty filter and size 25", () async {
      final repository = FakeAssetRepository(seed: [makeAsset()]);

      final result = await QueryAssets(assetRepository: repository).execute();

      expect(result.length, 1);
      expect(repository.lastQuery!.filter, isEmpty);
      expect(repository.lastQuery!.cursor, isNull);
      expect(repository.lastQuery!.size, 25);
    });
  });
}
