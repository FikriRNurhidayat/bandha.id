import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/deposit_fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../support/fakes.dart';
import '../../../../../support/fixtures.dart';
import '../../../../../support/funds_fakes.dart';

void main() {
  group("DepositFund", () {
    late FakeFundRepository repository;
    late FakeEntryWriter writer;
    late FakeUnitOfWork unitOfWork;
    late DepositFund useCase;
    final fundLabel = makeLabel(name: "Goal");
    late final fund = makeFund(
      amount: 1000,
      balance: 100,
      raised: 200,
      labels: [fundLabel],
    );

    DepositFund build(FakeLabelReader labelReader) => DepositFund(
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
      useCase = build(FakeLabelReader([depositLabel]));
    });

    test("raises balance and raised by the absolute amount", () async {
      await useCase.execute(fund.id, note: "Top up", amount: 300);

      expect(unitOfWork.executions, 1);
      final saved = repository.store[fund.id]!;
      expect(saved.balance, 400);
      expect(saved.raised, 500);
      expect(saved.amount, 1000);
    });

    test("treats negative input as its absolute value", () async {
      final entry = await useCase.execute(fund.id, note: null, amount: -300);

      expect(repository.store[fund.id]!.balance, 400);
      expect(repository.store[fund.id]!.raised, 500);
      expect(entry.amount, -300);
    });

    test("creates a read-only outflow entry controlled by the fund", () async {
      final before = DateTime.now();
      final entry = await useCase.execute(fund.id, note: "Top up", amount: 300);

      expect(writer.created, [entry]);
      expect(entry.amount, -300);
      expect(entry.note, "Top up");
      expect(entry.readOnly, isTrue);
      expect(entry.status, EntryStatus.done);
      expect(entry.controller!.id, fund.id);
      expect(entry.controller!.type, "Fund");
      expect(entry.journalId, fund.journalId);
      expect(entry.journal, fund.journal);
      expect(entry.categoryId, fund.categoryId);
      expect(entry.category, fund.category);
      expect(entry.labels, [fundLabel, depositLabel]);
      expect(entry.issuedAt.isBefore(before), isFalse);
    });

    test("fails without saving when the deposit label is missing", () async {
      useCase = build(FakeLabelReader());

      await expectLater(
        useCase.execute(fund.id, note: null, amount: 1),
        throwsException,
      );
      expect(repository.saved, isEmpty);
      expect(writer.created, isEmpty);
    });

    test("fails when the fund is missing", () async {
      await expectLater(
        useCase.execute("missing", note: null, amount: 1),
        throwsException,
      );
      expect(writer.created, isEmpty);
    });
  });
}
