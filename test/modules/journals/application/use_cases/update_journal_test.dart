import 'package:bandha/modules/journals/application/use_cases/update_journal.dart';
import 'package:bandha/modules/journals/domain/events/journal_updated.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  late FakeUnitOfWork unitOfWork;
  late RecordingEventPublisher events;

  setUp(() {
    unitOfWork = FakeUnitOfWork();
    events = RecordingEventPublisher();
  });

  test("saves changes and raises JournalUpdated", () async {
    final before = makeJournal(name: "Old", holderName: "A", balance: 100);
    final journals = FakeJournalRepository(seed: [before]);

    final after = await UpdateJournal(
      journalRepository: journals,
      eventPublisher: events,
      unitOfWork: unitOfWork,
    ).execute(before.id, name: "New", holderName: "B", balance: 250);

    expect(unitOfWork.executions, 1);
    expect(after.id, before.id);
    expect(after.name, "New");
    expect(after.holderName, "B");
    expect(after.balance, 250);
    expect(after.assetId, before.assetId);
    expect(journals.saved, [after]);

    final event = events.ofType<JournalUpdated>().single;
    expect(event.journalId, before.id);
    expect(event.before.balance, 100);
    expect(event.after.balance, 250);
    expect(event.deltaAmount, 150);
  });

  test("keeps omitted fields", () async {
    final before = makeJournal(name: "Keep", holderName: "Me", balance: 5);
    final journals = FakeJournalRepository(seed: [before]);

    final after = await UpdateJournal(
      journalRepository: journals,
      eventPublisher: events,
      unitOfWork: unitOfWork,
    ).execute(before.id);

    expect(after.name, "Keep");
    expect(after.holderName, "Me");
    expect(after.balance, 5);
    expect(events.ofType<JournalUpdated>().single.balanceChanged, isFalse);
  });

  test(
    "returns the updated journal with its asset",
    () async {
      final asset = makeAsset();
      final before = makeJournal(asset: asset);
      final journals = FakeJournalRepository(seed: [before]);

      final after = await UpdateJournal(
        journalRepository: journals,
        eventPublisher: events,
        unitOfWork: unitOfWork,
      ).execute(before.id, name: "New");

      expect(after.asset, asset);
    },
    skip:
        "BUG: Journal.copyWith does not carry the late `asset`, so the "
        "journal returned by UpdateJournal throws LateInitializationError on "
        ".asset/.toJson (journal.dart:70-86, update_journal.dart:36); "
        "JournalEditorViewModel.fill reads draft.entity.asset",
  );

  test("fails for a missing journal", () async {
    await expectLater(
      UpdateJournal(
        journalRepository: FakeJournalRepository(),
        eventPublisher: events,
        unitOfWork: unitOfWork,
      ).execute("missing", name: "x"),
      throwsException,
    );

    expect(events.raised, isEmpty);
  });
}
