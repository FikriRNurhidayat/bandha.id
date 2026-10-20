import 'package:bandha/modules/funds/application/use_cases/create_fund.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';
import '../../../../support/funds_fakes.dart';

void main() {
  group("CreateFund", () {
    late FakeFundRepository repository;
    late FakeUnitOfWork unitOfWork;
    late CreateFund useCase;
    final journal = makeJournal();
    final category = makeCategory();
    final labelA = makeLabel(name: "A");
    final labelB = makeLabel(name: "B");

    setUp(() {
      repository = FakeFundRepository();
      unitOfWork = FakeUnitOfWork();
      useCase = CreateFund(
        fundRepository: repository,
        unitOfWork: unitOfWork,
        categoryReader: FakeCategoryReader([category]),
        labelReader: FakeLabelReader([labelA, labelB]),
        journalReader: FakeJournalReader([journal]),
      );
    });

    test("saves a new active, hydrated fund", () async {
      final fund = await useCase.execute(
        note: "Trip",
        amount: 750,
        categoryId: category.id,
        journalId: journal.id,
        labelIds: [labelA.id, labelB.id],
      );

      expect(unitOfWork.executions, 1);
      expect(repository.saved, [fund]);
      expect(fund.note, "Trip");
      expect(fund.amount, 750);
      expect(fund.balance, 0);
      expect(fund.raised, 0);
      expect(fund.status, FundStatus.active);
      expect(fund.categoryId, category.id);
      expect(fund.journalId, journal.id);
      expect(fund.category, category);
      expect(fund.journal, journal);
      expect(fund.labels, [labelA, labelB]);
    });

    test("defaults to no labels", () async {
      final fund = await useCase.execute(
        note: null,
        amount: 1,
        categoryId: category.id,
        journalId: journal.id,
      );
      expect(fund.labels, isEmpty);
      expect(fund.note, isNull);
    });

    test("fails and saves nothing when the journal is missing", () async {
      await expectLater(
        useCase.execute(
          note: null,
          amount: 1,
          categoryId: category.id,
          journalId: "missing",
        ),
        throwsException,
      );
      expect(repository.saved, isEmpty);
    });

    test("fails and saves nothing when the category is missing", () async {
      await expectLater(
        useCase.execute(
          note: null,
          amount: 1,
          categoryId: "missing",
          journalId: journal.id,
        ),
        throwsException,
      );
      expect(repository.saved, isEmpty);
    });
  });
}
