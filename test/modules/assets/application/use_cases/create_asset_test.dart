import 'package:bandha/modules/assets/application/use_cases/create_asset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';

void main() {
  group("CreateAsset", () {
    test("saves and returns a new zero-balance asset", () async {
      final repository = FakeAssetRepository();
      final useCase = CreateAsset(assetRepository: repository);

      final asset = await useCase.execute(name: "Rupiah", code: "IDR");

      expect(asset.name, "Rupiah");
      expect(asset.code, "IDR");
      expect(asset.balance, 0);
      expect(repository.saved, [asset]);
      expect(repository.store[asset.id], same(asset));
    });
  });
}
