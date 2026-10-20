import 'package:bandha/core/domain/constants/system_categories.dart';
import 'package:bandha/modules/entries/application/event_handlers/create_entry_on_journal_created.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/journals/domain/events/journal_created.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  late FakeEntryRepository entries;
  late RecordingEventPublisher events;
  late CreateEntryOnJournalCreated handler;

  setUp(() {
    entries = FakeEntryRepository();
    events = RecordingEventPublisher();
    handler = CreateEntryOnJournalCreated(
      entryRepository: entries,
      eventPublisher: events,
    );
  });

  test("does nothing for a zero opening balance", () async {
    await handler.handle(JournalCreated.fromJournal(makeJournal(balance: 0)));

    expect(entries.saved, isEmpty);
    expect(events.raised, isEmpty);
  });

  test(
    "creates a read-only adjustment entry for the opening balance",
    () async {
      final journal = makeJournal(balance: 50000);
      final event = JournalCreated.fromJournal(journal);

      await handler.handle(event);

      final entry = entries.saved.single;
      expect(entry.readOnly, isTrue);
      expect(entry.note, "Balance adjustment");
      expect(entry.amount, 50000);
      expect(entry.status, EntryStatus.done);
      expect(entry.journalId, journal.id);
      expect(entry.categoryId, SystemCategories.adjustmentId);
      expect(entry.controller?.id, journal.id);
      expect(entry.controller?.type, "Journal");
      expect(entry.issuedAt, event.occurredAt);

      final created = events.ofType<EntryCreated>().single;
      expect(created.entryId, entry.id);
      expect(created.skip, isTrue);
      expect(created.snapshot.journalId, journal.id);
      expect(created.snapshot.assetId, journal.assetId);
      expect(created.snapshot.amount, 50000);
    },
  );

  test("handles negative opening balances", () async {
    await handler.handle(JournalCreated.fromJournal(makeJournal(balance: -5)));

    expect(entries.saved.single.amount, -5);
  });
}
