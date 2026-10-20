import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';
import 'package:bandha/modules/journals/application/event_handlers/update_journal_balance_on_entry_created.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fixtures.dart';

void main() {
  test("increments the journal balance by the entry amount", () async {
    final journals = FakeJournalRepository();
    final journal = makeJournal();

    await UpdateJournalBalanceOnEntryCreated(journals).handle(
      EntryCreated.fromEntry(makeEntry(journal: journal, amount: -1200)),
    );

    expect(journals.increments, [(id: journal.id, delta: -1200.0)]);
  });

  test("ignores events flagged with skip", () async {
    final journals = FakeJournalRepository();

    await UpdateJournalBalanceOnEntryCreated(journals).handle(
      EntryCreated(
        entryId: "e",
        snapshot: EntrySnapshot(journalId: "j", assetId: "a", amount: 500),
        skip: true,
      ),
    );

    expect(journals.increments, isEmpty);
  });

  test("handleAll applies each non-skipped event", () async {
    final journals = FakeJournalRepository();

    await UpdateJournalBalanceOnEntryCreated(journals).handleAll([
      EntryCreated(
        entryId: "e1",
        snapshot: EntrySnapshot(journalId: "j", assetId: "a", amount: 1),
      ),
      EntryCreated(
        entryId: "e2",
        snapshot: EntrySnapshot(journalId: "j", assetId: "a", amount: 2),
        skip: true,
      ),
      EntryCreated(
        entryId: "e3",
        snapshot: EntrySnapshot(journalId: "k", assetId: "a", amount: 3),
      ),
    ]);

    expect(journals.increments, [(id: "j", delta: 1.0), (id: "k", delta: 3.0)]);
  });
}
