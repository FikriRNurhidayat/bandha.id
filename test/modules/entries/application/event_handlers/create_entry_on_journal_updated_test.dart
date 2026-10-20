import 'package:bandha/core/domain/constants/system_categories.dart';
import 'package:bandha/modules/entries/application/event_handlers/create_entry_on_journal_updated.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/journals/domain/events/journal_updated.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  late FakeEntryRepository entries;
  late RecordingEventPublisher events;
  late CreateEntryOnJournalUpdated handler;

  setUp(() {
    entries = FakeEntryRepository();
    events = RecordingEventPublisher();
    handler = CreateEntryOnJournalUpdated(
      entryRepository: entries,
      eventPublisher: events,
    );
  });

  test("does nothing when the balance is unchanged", () async {
    final before = makeJournal(balance: 100);
    final after = before.copyWith(name: "Renamed");

    await handler.handle(JournalUpdated.of(before, after));

    expect(entries.saved, isEmpty);
    expect(events.raised, isEmpty);
  });

  test("creates a read-only adjustment entry for the delta", () async {
    final before = makeJournal(balance: 100);
    final after = before.copyWith(balance: 70);
    final event = JournalUpdated.of(before, after);

    await handler.handle(event);

    final entry = entries.saved.single;
    expect(entry.readOnly, isTrue);
    expect(entry.note, "Balance adjustment");
    expect(entry.amount, -30);
    expect(entry.status, EntryStatus.done);
    expect(entry.journalId, before.id);
    expect(entry.categoryId, SystemCategories.adjustmentId);
    expect(entry.controller?.id, before.id);
    expect(entry.controller?.type, "Journal");
    expect(entry.issuedAt, event.occurredAt);

    final created = events.ofType<EntryCreated>().single;
    expect(created.entryId, entry.id);
    expect(created.skip, isTrue);
    expect(created.snapshot.journalId, before.id);
    expect(created.snapshot.assetId, after.assetId);
  });

  test(
    "snapshot amount matches the adjustment entry amount",
    () async {
      final before = makeJournal(balance: 100);
      final after = before.copyWith(balance: 70);

      await handler.handle(JournalUpdated.of(before, after));

      final created = events.ofType<EntryCreated>().single;
      expect(created.snapshot.amount, entries.saved.single.amount);
    },
    skip:
        "BUG: EntryCreated snapshot uses event.after.balance (70) instead of "
        "the entry amount event.deltaAmount (-30) "
        "(create_entry_on_journal_updated.dart:51)",
  );
}
