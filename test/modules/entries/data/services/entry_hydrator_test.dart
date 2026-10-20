import 'package:bandha/modules/entries/data/services/entry_hydrator.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fixtures.dart';

Entry bareEntry({required String journalId, required String categoryId}) {
  return Entry(
    id: "e-$journalId-$categoryId",
    amount: 1,
    status: EntryStatus.done,
    readOnly: false,
    journalId: journalId,
    categoryId: categoryId,
    issuedAt: fixedTime,
    createdAt: fixedTime,
    updatedAt: fixedTime,
  );
}

void main() {
  final j1 = makeJournal();
  final j2 = makeJournal();
  final c1 = makeCategory();
  final label = makeLabel();

  late FakeJournalReader journals;
  late FakeCategoryReader categories;
  late EntryHydrator hydrator;

  setUp(() {
    journals = FakeJournalReader([j1, j2]);
    categories = FakeCategoryReader([c1]);
  });

  test("attaches journal, category and labels", () async {
    final a = bareEntry(journalId: j1.id, categoryId: c1.id);
    final b = bareEntry(journalId: j2.id, categoryId: c1.id);
    hydrator = EntryHydrator(
      journalReader: journals,
      categoryReader: categories,
      labelReader: FakeLabelReader(const [], {
        a.id: [label],
      }),
    );

    final result = (await hydrator.hydrateAll([a, b])).toList();

    expect(result[0].journal, j1);
    expect(result[0].category, c1);
    expect(result[0].labels, [label]);
    expect(result[1].journal, j2);
    expect(result[1].labels, isEmpty);
  });

  test("looks up each journal and category once", () async {
    hydrator = EntryHydrator(
      journalReader: journals,
      categoryReader: categories,
      labelReader: FakeLabelReader(),
    );

    await hydrator.hydrateAll([
      bareEntry(journalId: j1.id, categoryId: c1.id),
      Entry(
        id: "other",
        amount: 2,
        status: EntryStatus.done,
        readOnly: false,
        journalId: j1.id,
        categoryId: c1.id,
        issuedAt: fixedTime,
        createdAt: fixedTime,
        updatedAt: fixedTime,
      ),
    ]);

    expect(journals.getAllCalls.single, [j1.id]);
    expect(categories.getAllCalls.single, [c1.id]);
  });

  test("hydrate returns the single hydrated entry", () async {
    hydrator = EntryHydrator(
      journalReader: journals,
      categoryReader: categories,
      labelReader: FakeLabelReader(),
    );

    final entry = await hydrator.hydrate(
      bareEntry(journalId: j2.id, categoryId: c1.id),
    );

    expect(entry.journal, j2);
    expect(entry.category, c1);
  });

  test("fails when a journal cannot be resolved", () async {
    hydrator = EntryHydrator(
      journalReader: journals,
      categoryReader: categories,
      labelReader: FakeLabelReader(),
    );

    await expectLater(
      hydrator.hydrate(bareEntry(journalId: "missing", categoryId: c1.id)),
      throwsA(isA<TypeError>()),
    );
  });
}
