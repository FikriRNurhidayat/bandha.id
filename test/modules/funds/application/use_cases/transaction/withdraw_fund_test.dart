import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/withdraw_fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../support/fakes.dart';
import '../../../../../support/fixtures.dart';
import '../../../../../support/funds_fakes.dart';

void main() {
  group("WithdrawFund", () {
    late FakeFundRepository repository;
    late FakeEntryWriter writer;
    late FakeUnitOfWork unitOfWork;
    late WithdrawFund useCase;
    final fundLabel = makeLabel(name: "Goal");
    late final fund = makeFund(
      amount: 1000,
      balance: 500,
      raised: 600,
      labels: [fundLabel],
    );

    WithdrawFund build(FakeLabelReader labelReader) => WithdrawFund(
      fundRepository: repository,
      unitOfWork: unitOfWork,
      labelReader: labelReader,
      journalReader: FakeJournalReader([fund.journal]),
      entryWriter: writer,
    );

    setUp(() {
      repository = FakeFundRepository(seed: [fund]);
      writer = FakeEntryWriter();
      unitOfWork = FakeUnitOfWork();
      useCase = build(FakeLabelReader([withdrawLabel]));
    });

    test("lowers balance and raised by the absolute amount", () async {
      await useCase.execute(fund.id, note: null, amount: 200);

      expect(unitOfWork.executions, 1);
      final saved = repository.store[fund.id]!;
      expect(saved.balance, 300);
      expect(saved.raised, 400);
    });

    test("treats negative input as its absolute value", () async {
      final entry = await useCase.execute(fund.id, note: null, amount: -200);

      expect(repository.store[fund.id]!.balance, 300);
      expect(repository.store[fund.id]!.raised, 400);
      expect(entry.amount, 200);
    });

    test("creates a read-only inflow entry controlled by the fund", () async {
      final before = DateTime.now();
      final entry = await useCase.execute(fund.id, note: "Back", amount: 200);

      expect(writer.created, [entry]);
      expect(entry.amount, 200);
      expect(entry.note, "Back");
      expect(entry.readOnly, isTrue);
      expect(entry.status, EntryStatus.done);
      expect(entry.controller!.id, fund.id);
      expect(entry.controller!.type, "Fund");
      expect(entry.journal, fund.journal);
      expect(entry.category, fund.category);
      expect(entry.categoryId, fund.categoryId);
      expect(entry.labels, [fundLabel, withdrawLabel]);
      expect(entry.issuedAt.isBefore(before), isFalse);
    });

    test("fails without saving when the withdraw label is missing", () async {
      useCase = build(FakeLabelReader());

      await expectLater(
        useCase.execute(fund.id, note: null, amount: 1),
        throwsException,
      );
      expect(repository.saved, isEmpty);
      expect(writer.created, isEmpty);
    });
  });
}
