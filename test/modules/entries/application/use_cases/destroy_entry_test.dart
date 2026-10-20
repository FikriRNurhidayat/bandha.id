import 'package:bandha/modules/entries/application/use_cases/destroy_entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  test("destroys the entry and raises EntryDestroyed", () async {
    final journal = makeJournal();
    final entry = makeEntry(journal: journal, amount: -300);
    final entries = FakeEntryRepository(seed: [entry]);
    final unitOfWork = FakeUnitOfWork();
    final events = RecordingEventPublisher();

    await DestroyEntry(
      entries,
      unitOfWork: unitOfWork,
      eventPublisher: events,
    ).execute(entry.id);

    expect(unitOfWork.executions, 1);
    expect(entries.destroyed, [entry]);
    expect(entries.store, isEmpty);

    final event = events.ofType<EntryDestroyed>().single;
    expect(event.entryId, entry.id);
    expect(event.snapshot.journalId, journal.id);
    expect(event.snapshot.amount, -300);
  });

  test("fails for a missing entry", () async {
    final entries = FakeEntryRepository();
    final events = RecordingEventPublisher();

    await expectLater(
      DestroyEntry(
        entries,
        unitOfWork: FakeUnitOfWork(),
        eventPublisher: events,
      ).execute("missing"),
      throwsException,
    );

    expect(entries.destroyed, isEmpty);
    expect(events.raised, isEmpty);
  });
}
