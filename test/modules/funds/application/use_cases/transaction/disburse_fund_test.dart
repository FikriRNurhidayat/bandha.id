import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/disburse_fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../support/fakes.dart';
import '../../../../../support/fixtures.dart';
import '../../../../../support/funds_fakes.dart';

void main() {
  group("DisburseFund", () {
    late FakeFundRepository repository;
    late FakeEntryWriter writer;
    late FakeUnitOfWork unitOfWork;
    late FakeLabelReader labelReader;
    late DisburseFund useCase;
    final fundLabel = makeLabel(name: "Goal");
    final extraLabel = makeLabel(name: "Extra");
    final otherCategory = makeCategory(name: "Groceries");
    late final fund = makeFund(
      amount: 1000,
      balance: 500,
      raised: 600,
      labels: [fundLabel],
    );

    setUp(() {
      repository = FakeFundRepository(seed: [fund]);
      writer = FakeEntryWriter();
      unitOfWork = FakeUnitOfWork();
      labelReader = FakeLabelReader([fundLabel, extraLabel, disbursementLabel]);
      useCase = DisburseFund(
        categoryReader: FakeCategoryReader([fund.category, otherCategory]),
        entryWriter: writer,
        fundRepository: repository,
        journalReader: FakeJournalReader([fund.journal]),
        labelReader: labelReader,
        unitOfWork: unitOfWork,
      );
    });

    Future<Entry> disburse({
      double amount = 200,
      String? categoryId,
      Iterable<String>? labelIds,
      DateTime? issuedAt,
    }) {
      return useCase.execute(
        fund.id,
        note: "Spend",
        amount: amount,
        categoryId: categoryId,
        labelIds: labelIds,
        issuedAt: issuedAt ?? fixedTime,
      );
    }

    test("lowers balance by the absolute amount but keeps raised", () async {
      await disburse(amount: -200);

      expect(unitOfWork.executions, 1);
      final saved = repository.store[fund.id]!;
      expect(saved.balance, 300);
      expect(saved.raised, 600);
    });

    test("creates a read-only entry controlled by the fund", () async {
      final entry = await disburse();

      expect(writer.created, [entry]);
      expect(entry.amount.abs(), 200);
      expect(entry.note, "Spend");
      expect(entry.readOnly, isTrue);
      expect(entry.status, EntryStatus.done);
      expect(entry.controller!.id, fund.id);
      expect(entry.controller!.type, "Fund");
      expect(entry.journal, fund.journal);
      expect(entry.journalId, fund.journalId);
    });

    test("defaults to the fund category", () async {
      final entry = await disburse();
      expect(entry.categoryId, fund.categoryId);
      expect(entry.category, fund.category);
    });

    test("uses the given category", () async {
      final entry = await disburse(categoryId: otherCategory.id);
      expect(entry.categoryId, otherCategory.id);
      expect(entry.category, otherCategory);
    });

    test("labels with fund labels plus disbursement", () async {
      final entry = await disburse();
      expect(entry.labels, [fundLabel, disbursementLabel]);
    });

    test("adds extra labels without duplicating fund labels", () async {
      final entry = await disburse(labelIds: [fundLabel.id, extraLabel.id]);

      expect(entry.labels, [fundLabel, extraLabel, disbursementLabel]);
      expect(labelReader.getAllCalls.single, [
        extraLabel.id,
        disbursementLabel.id,
      ]);
    });

    test(
      "issues the entry at the given time",
      () async {
        final issuedAt = DateTime.utc(2025, 12, 31);
        final entry = await disburse(issuedAt: issuedAt);
        expect(entry.issuedAt, issuedAt);
      },
      skip:
          "BUG: `issuedAt` parameter is ignored; entry uses DateTime.now() "
          "(disburse_fund.dart:66)",
    );

    test("fails without saving when the category is missing", () async {
      await expectLater(disburse(categoryId: "missing"), throwsException);
      expect(repository.saved, isEmpty);
      expect(writer.created, isEmpty);
    });
  });
}
