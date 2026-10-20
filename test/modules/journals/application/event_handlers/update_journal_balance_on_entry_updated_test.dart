import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';
import 'package:bandha/modules/journals/application/event_handlers/update_journal_balance_on_entry_updated.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';

EntryUpdated updated({
  String fromJournal = "j",
  String toJournal = "j",
  String fromAsset = "a",
  String toAsset = "a",
  required double fromAmount,
  required double toAmount,
}) {
  return EntryUpdated(
    entryId: "e",
    before: EntrySnapshot(
      journalId: fromJournal,
      assetId: fromAsset,
      amount: fromAmount,
    ),
    after: EntrySnapshot(
      journalId: toJournal,
      assetId: toAsset,
      amount: toAmount,
    ),
  );
}

void main() {
  late FakeJournalRepository journals;
  late UpdateJournalBalanceOnEntryUpdated handler;

  setUp(() {
    journals = FakeJournalRepository();
    handler = UpdateJournalBalanceOnEntryUpdated(journals);
  });

  test("does nothing without balance impact", () async {
    await handler.handle(updated(fromAmount: 10, toAmount: 10));

    expect(journals.increments, isEmpty);
  });

  test("reverts the old amount and applies the new one", () async {
    await handler.handle(updated(fromAmount: -100, toAmount: -250));

    expect(journals.increments, [
      (id: "j", delta: 100.0),
      (id: "j", delta: -250.0),
    ]);
  });

  test("moves the amount between journals", () async {
    await handler.handle(
      updated(
        fromJournal: "j1",
        toJournal: "j2",
        fromAmount: -40,
        toAmount: -40,
      ),
    );

    expect(journals.increments, [
      (id: "j1", delta: 40.0),
      (id: "j2", delta: -40.0),
    ]);
  });
}
