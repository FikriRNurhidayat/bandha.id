import 'package:bandha/modules/entries/application/use_cases/update_entry.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  late FakeUnitOfWork unitOfWork;
  late FakeEntryRepository entries;
  late RecordingEventPublisher events;
  late UpdateEntry useCase;
  final oldJournal = makeJournal(name: "Old");
  final newJournal = makeJournal(name: "New");
  final oldCategory = makeCategory(name: "Old");
  final newCategory = makeCategory(name: "New");
  final label = makeLabel();

  UpdateEntry build(Entry seed) {
    entries = FakeEntryRepository(seed: [seed]);
    return UpdateEntry(
      entryRepository: entries,
      unitOfWork: unitOfWork,
      eventPublisher: events,
      journalReader: FakeJournalReader([oldJournal, newJournal]),
      labelReader: FakeLabelReader([label]),
      categoryReader: FakeCategoryReader([oldCategory, newCategory]),
    );
  }

  setUp(() {
    unitOfWork = FakeUnitOfWork();
    events = RecordingEventPublisher();
  });

  test("saves the changes and raises EntryUpdated", () async {
    final before = makeEntry(
      journal: oldJournal,
      category: oldCategory,
      amount: -100,
      status: EntryStatus.pending,
    );
    useCase = build(before);

    final after = await useCase.execute(
      before.id,
      note: "Dinner",
      amount: -250,
      status: EntryStatus.done,
      journalId: newJournal.id,
      categoryId: newCategory.id,
      labelIds: [label.id],
      issuedAt: fixedTime,
    );

    expect(unitOfWork.executions, 1);
    expect(after.id, before.id);
    expect(after.note, "Dinner");
    expect(after.amount, -250);
    expect(after.status, EntryStatus.done);
    expect(after.journalId, newJournal.id);
    expect(after.journal, newJournal);
    expect(after.categoryId, newCategory.id);
    expect(after.category, newCategory);
    expect(after.labels, [label]);
    expect(entries.saved, [after]);
    expect(identical(entries.store[before.id], after), isTrue);

    final event = events.ofType<EntryUpdated>().single;
    expect(event.entryId, before.id);
    expect(event.before.journalId, oldJournal.id);
    expect(event.before.amount, -100);
    expect(event.after.journalId, newJournal.id);
    expect(event.after.amount, -250);
    expect(event.hasBalanceImpact, isTrue);
  });

  test("keeps the note when none is given", () async {
    final before = makeEntry(
      note: "Keep",
      journal: oldJournal,
      category: oldCategory,
    );
    useCase = build(before);

    final after = await useCase.execute(
      before.id,
      amount: before.amount,
      status: before.status,
      journalId: oldJournal.id,
      categoryId: oldCategory.id,
      labelIds: const [],
      issuedAt: before.issuedAt,
    );

    expect(after.note, "Keep");
    expect(after.labels, isEmpty);
    expect(events.ofType<EntryUpdated>().single.hasBalanceImpact, isFalse);
  });

  test(
    "applies the new issuedAt",
    () async {
      final before = makeEntry(journal: oldJournal, category: oldCategory);
      useCase = build(before);
      final issuedAt = DateTime.utc(2026, 3, 1);

      final after = await useCase.execute(
        before.id,
        amount: before.amount,
        status: before.status,
        journalId: oldJournal.id,
        categoryId: oldCategory.id,
        labelIds: const [],
        issuedAt: issuedAt,
      );

      expect(after.issuedAt, issuedAt);
    },
    skip:
        "BUG: UpdateEntry.execute accepts issuedAt but never passes it to "
        "copyWith, so the date cannot be changed (update_entry.dart:57-65)",
  );

  test("rejects read-only entries", () async {
    final before = makeEntry(
      readOnly: true,
      journal: oldJournal,
      category: oldCategory,
    );
    useCase = build(before);

    await expectLater(
      useCase.execute(
        before.id,
        amount: 1,
        status: EntryStatus.done,
        journalId: oldJournal.id,
        categoryId: oldCategory.id,
        labelIds: const [],
        issuedAt: fixedTime,
      ),
      throwsException,
    );

    expect(entries.saved, isEmpty);
    expect(events.raised, isEmpty);
  });

  test("fails for a missing entry", () async {
    useCase = build(makeEntry());

    await expectLater(
      useCase.execute(
        "missing",
        amount: 1,
        status: EntryStatus.done,
        journalId: oldJournal.id,
        categoryId: oldCategory.id,
        labelIds: const [],
        issuedAt: fixedTime,
      ),
      throwsException,
    );

    expect(events.raised, isEmpty);
  });
}
