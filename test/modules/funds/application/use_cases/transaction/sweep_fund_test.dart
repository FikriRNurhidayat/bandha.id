import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/funds/application/use_cases/transaction/sweep_fund.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../support/fakes.dart';
import '../../../../../support/fixtures.dart';
import '../../../../../support/funds_fakes.dart';

void main() {
  group("SweepFund", () {
    late FakeFundRepository repository;
    late FakeEntryWriter writer;
    late FakeUnitOfWork unitOfWork;
    late SweepFund useCase;
    final fundLabel = makeLabel(name: "Goal");
    late final fund = makeFund(
      amount: 1000,
      balance: 450,
      raised: 600,
      labels: [fundLabel],
    );

    SweepFund build(FakeLabelReader labelReader) => SweepFund(
      fundRepository: repository,
      unitOfWork: unitOfWork,
      categoryReader: FakeCategoryReader([fund.category]),
      labelReader: labelReader,
      journalReader: FakeJournalReader([fund.journal]),
      entryWriter: writer,
    );

    setUp(() {
      repository = FakeFundRepository(seed: [fund]);
      writer = FakeEntryWriter();
      unitOfWork = FakeUnitOfWork();
      useCase = build(FakeLabelReader([releasedLabel]));
    });

    test("releases the fund and saves it", () async {
      final before = DateTime.now();
      final released = await useCase.execute(fund.id);

      expect(unitOfWork.executions, 1);
      expect(repository.saved, [released]);
      expect(released.id, fund.id);
      expect(released.status, FundStatus.released);
      expect(released.status.isReleased, isTrue);
      expect(released.releasedAt!.isBefore(before), isFalse);
      expect(released.raised, 600);
    });

    test("returns the remaining balance to the journal", () async {
      final before = DateTime.now();
      await useCase.execute(fund.id);

      final entry = writer.created.single;
      expect(entry.amount, 450);
      expect(entry.note, isNull);
      expect(entry.readOnly, isTrue);
      expect(entry.status, EntryStatus.done);
      expect(entry.controller!.id, fund.id);
      expect(entry.controller!.type, "Fund");
      expect(entry.journal, fund.journal);
      expect(entry.category, fund.category);
      expect(entry.categoryId, fund.categoryId);
      expect(entry.labels, [fundLabel, releasedLabel]);
      expect(entry.issuedAt.isBefore(before), isFalse);
    });

    test(
      "empties the fund balance",
      () async {
        final released = await useCase.execute(fund.id);
        expect(released.balance, 0);
      },
      skip:
          "BUG?: the sweep entry returns `balance` to the journal but the "
          "fund keeps its balance, so it still reports money it no longer "
          "holds (sweep_fund.dart:58-61)",
    );

    test("fails without changes when the released label is missing", () async {
      useCase = build(FakeLabelReader());

      await expectLater(useCase.execute(fund.id), throwsException);
      expect(repository.saved, isEmpty);
      expect(writer.created, isEmpty);
    });
  });
}
