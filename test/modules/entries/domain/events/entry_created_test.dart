import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  test("fromEntry snapshots the entry and does not skip", () {
    final journal = makeJournal();
    final entry = makeEntry(journal: journal, amount: 300);
    final event = EntryCreated.fromEntry(entry);

    expect(event.entryId, entry.id);
    expect(event.snapshot.journalId, journal.id);
    expect(event.snapshot.assetId, journal.asset.id);
    expect(event.snapshot.amount, 300);
    expect(event.skip, isFalse);
  });

  test("skip can be set explicitly", () {
    final event = EntryCreated(
      entryId: "e",
      snapshot: EntrySnapshot(journalId: "j", assetId: "a", amount: 1),
      skip: true,
    );

    expect(event.skip, isTrue);
  });
}
