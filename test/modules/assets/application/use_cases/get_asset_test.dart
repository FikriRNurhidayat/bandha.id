import 'package:bandha/modules/assets/application/use_cases/get_asset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  group("GetAsset", () {
    test("returns the asset by id", () async {
      final asset = makeAsset(id: "a");
      final repository = FakeAssetRepository(seed: [asset]);
      final useCase = GetAsset(assetRepository: repository);

      expect(useCase.repository, same(repository));
      expect(await useCase.execute("a"), same(asset));
    });

    test("propagates not found errors", () async {
      final useCase = GetAsset(assetRepository: FakeAssetRepository());

      await expectLater(useCase.execute("missing"), throwsException);
    });
  });
}
