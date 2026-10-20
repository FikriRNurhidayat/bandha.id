import 'package:bandha/modules/assets/application/use_cases/update_asset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  group("UpdateAsset", () {
    late FakeAssetRepository repository;
    late FakeUnitOfWork unitOfWork;
    late UpdateAsset useCase;

    setUp(() {
      repository = FakeAssetRepository(
        seed: [makeAsset(id: "a", name: "Rupiah", code: "IDR", balance: 50)],
      );
      unitOfWork = FakeUnitOfWork();
      useCase = UpdateAsset(
        assetRepository: repository,
        unitOfWork: unitOfWork,
      );
    });

    test("updates name and code inside a unit of work", () async {
      final asset = await useCase.execute("a", name: "Dollar", code: "USD");

      expect(asset.id, "a");
      expect(asset.name, "Dollar");
      expect(asset.code, "USD");
      expect(asset.balance, 50);
      expect(repository.store["a"]!.name, "Dollar");
      expect(repository.saved, [asset]);
      expect(unitOfWork.executions, 1);
    });

    test("keeps fields that are not given", () async {
      final asset = await useCase.execute("a", name: "Rp");

      expect(asset.name, "Rp");
      expect(asset.code, "IDR");
    });

    test("propagates missing asset errors without saving", () async {
      await expectLater(useCase.execute("missing", name: "X"), throwsException);
      expect(repository.saved, isEmpty);
    });
  });
}
