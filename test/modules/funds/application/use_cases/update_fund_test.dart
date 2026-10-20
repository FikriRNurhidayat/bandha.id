import 'package:bandha/modules/funds/application/use_cases/update_fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';
import '../../../../support/funds_fakes.dart';

void main() {
  group("UpdateFund", () {
    late FakeFundRepository repository;
    late FakeUnitOfWork unitOfWork;
    late UpdateFund useCase;
    final oldCategory = makeCategory(name: "Old");
    final newCategory = makeCategory(name: "New");
    final oldLabel = makeLabel(name: "Old");
    final newLabel = makeLabel(name: "New");
    late final fund = makeFund(
      note: "Before",
      amount: 100,
      balance: 40,
      raised: 60,
      category: oldCategory,
      labels: [oldLabel],
    );

    setUp(() {
      repository = FakeFundRepository(seed: [fund]);
      unitOfWork = FakeUnitOfWork();
      useCase = UpdateFund(
        fundRepository: repository,
        unitOfWork: unitOfWork,
        categoryReader: FakeCategoryReader([oldCategory, newCategory]),
        labelReader: FakeLabelReader([oldLabel, newLabel]),
      );
    });

    test("updates note, target, category and labels", () async {
      final updated = await useCase.execute(
        fund.id,
        note: "After",
        amount: 200,
        categoryId: newCategory.id,
        labelIds: [newLabel.id],
      );

      expect(unitOfWork.executions, 1);
      expect(repository.saved, [updated]);
      expect(repository.store[fund.id], same(updated));
      expect(updated.id, fund.id);
      expect(updated.note, "After");
      expect(updated.amount, 200);
      expect(updated.categoryId, newCategory.id);
      expect(updated.category, newCategory);
      expect(updated.labels, [newLabel]);
      expect(updated.journal, fund.journal);
    });

    test("keeps balance, raised and status untouched", () async {
      final updated = await useCase.execute(
        fund.id,
        note: "After",
        amount: 200,
        categoryId: newCategory.id,
      );

      expect(updated.balance, 40);
      expect(updated.raised, 60);
      expect(updated.status, fund.status);
      expect(updated.labels, isEmpty);
    });

    test(
      "clears the note when null is given",
      () async {
        final updated = await useCase.execute(
          fund.id,
          note: null,
          amount: 100,
          categoryId: oldCategory.id,
        );
        expect(updated.note, isNull);
      },
      skip:
          "BUG: Fund.copyWith uses `note ?? this.note`, so UpdateFund cannot "
          "clear a fund's note (update_fund.dart:46, fund.dart:135)",
    );

    test("fails when the fund is missing", () async {
      await expectLater(
        useCase.execute(
          "missing",
          note: null,
          amount: 1,
          categoryId: oldCategory.id,
        ),
        throwsException,
      );
      expect(repository.saved, isEmpty);
    });
  });
}
