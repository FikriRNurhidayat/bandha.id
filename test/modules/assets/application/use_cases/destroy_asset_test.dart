import 'package:bandha/modules/assets/application/use_cases/destroy_asset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  group("DestroyAsset", () {
    test("destroys the asset fetched by id", () async {
      final asset = makeAsset(id: "a");
      final repository = FakeAssetRepository(seed: [asset]);

      await DestroyAsset(repository).execute("a");

      expect(repository.destroyed, [asset]);
      expect(repository.store, isEmpty);
    });

    test("propagates not found errors without destroying", () async {
      final repository = FakeAssetRepository();

      await expectLater(DestroyAsset(repository).execute("x"), throwsException);
      expect(repository.destroyed, isEmpty);
    });
  });
}
