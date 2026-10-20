import 'package:bandha/modules/funds/data/services/fund_hydrator.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';
import '../../../../support/funds_fakes.dart';

Fund rawFund(
  String id, {
  required String journalId,
  required String categoryId,
}) {
  return Fund(
    id: id,
    note: null,
    amount: 100,
    balance: 0,
    raised: 0,
    status: FundStatus.active,
    categoryId: categoryId,
    journalId: journalId,
    createdAt: fixedTime,
    updatedAt: fixedTime,
    releasedAt: null,
  );
}

void main() {
  group("FundHydrator", () {
    final journalA = makeJournal(name: "A");
    final journalB = makeJournal(name: "B");
    final category = makeCategory();
    final label = makeLabel();
    late FakeJournalReader journalReader;
    late FakeCategoryReader categoryReader;
    late FundHydrator hydrator;

    setUp(() {
      journalReader = FakeJournalReader([journalA, journalB]);
      categoryReader = FakeCategoryReader([category]);
      hydrator = FundHydrator(
        journalReader: journalReader,
        categoryReader: categoryReader,
        labelReader: FakeLabelReader(
          [label],
          {
            "f1": [label],
          },
        ),
      );
    });

    test("hydrates journal, category and labels", () async {
      final fund = await hydrator.hydrate(
        rawFund("f1", journalId: journalA.id, categoryId: category.id),
      );

      expect(fund.journal, journalA);
      expect(fund.category, category);
      expect(fund.labels, [label]);
    });

    test("defaults to no labels", () async {
      final fund = await hydrator.hydrate(
        rawFund("f2", journalId: journalA.id, categoryId: category.id),
      );
      expect(fund.labels, isEmpty);
    });

    test("batches lookups by distinct ids", () async {
      final funds = (await hydrator.hydrateAll([
        rawFund("f1", journalId: journalA.id, categoryId: category.id),
        rawFund("f2", journalId: journalB.id, categoryId: category.id),
        rawFund("f3", journalId: journalA.id, categoryId: category.id),
      ])).toList();

      expect(funds.map((f) => f.journal), [journalA, journalB, journalA]);
      expect(journalReader.getAllCalls.single, [journalA.id, journalB.id]);
      expect(categoryReader.getAllCalls.single, [category.id]);
    });

    test("throws when a referenced journal is missing", () async {
      expect(
        () => hydrator.hydrate(
          rawFund("f1", journalId: "missing", categoryId: category.id),
        ),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
