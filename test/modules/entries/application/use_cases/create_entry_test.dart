import 'package:bandha/modules/entries/application/use_cases/create_entry.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  late FakeUnitOfWork unitOfWork;
  late FakeEntryRepository entries;
  late RecordingEventPublisher events;
  final journal = makeJournal();
  final category = makeCategory();
  final label = makeLabel();
  late CreateEntry useCase;

  setUp(() {
    unitOfWork = FakeUnitOfWork();
    entries = FakeEntryRepository();
    events = RecordingEventPublisher();
    useCase = CreateEntry(
      unitOfWork: unitOfWork,
      entryRepository: entries,
      eventPublisher: events,
      journalReader: FakeJournalReader([journal]),
      labelReader: FakeLabelReader([label]),
      categoryReader: FakeCategoryReader([category]),
    );
  });

  test("saves a hydrated entry and raises EntryCreated", () async {
    final entry = await useCase.execute(
      note: "Lunch",
      amount: -15000,
      status: EntryStatus.done,
      journalId: journal.id,
      categoryId: category.id,
      issuedAt: fixedTime,
      labelIds: [label.id],
    );

    expect(unitOfWork.executions, 1);
    expect(entries.saved, [entry]);
    expect(entry.note, "Lunch");
    expect(entry.amount, -15000);
    expect(entry.status, EntryStatus.done);
    expect(entry.readOnly, isFalse);
    expect(entry.journal, journal);
    expect(entry.category, category);
    expect(entry.labels, [label]);
    expect(entry.issuedAt, fixedTime);

    final raised = events.ofType<EntryCreated>().single;
    expect(raised.entryId, entry.id);
    expect(raised.snapshot.journalId, journal.id);
    expect(raised.snapshot.assetId, journal.asset.id);
    expect(raised.snapshot.amount, -15000);
    expect(raised.skip, isFalse);
  });

  test("defaults to no labels", () async {
    final entry = await useCase.execute(
      note: "Lunch",
      amount: 1,
      status: EntryStatus.pending,
      journalId: journal.id,
      categoryId: category.id,
      issuedAt: fixedTime,
    );

    expect(entry.labels, isEmpty);
  });

  test("fails without saving when the journal is missing", () async {
    await expectLater(
      useCase.execute(
        note: "Lunch",
        amount: 1,
        status: EntryStatus.done,
        journalId: "missing",
        categoryId: category.id,
        issuedAt: fixedTime,
      ),
      throwsException,
    );

    expect(entries.saved, isEmpty);
    expect(events.raised, isEmpty);
  });

  test("fails without saving when the category is missing", () async {
    await expectLater(
      useCase.execute(
        note: "Lunch",
        amount: 1,
        status: EntryStatus.done,
        journalId: journal.id,
        categoryId: "missing",
        issuedAt: fixedTime,
      ),
      throwsException,
    );

    expect(entries.saved, isEmpty);
    expect(events.raised, isEmpty);
  });
}
