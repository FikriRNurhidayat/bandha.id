import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  test("fromEntry snapshots the entry", () {
    final journal = makeJournal();
    final entry = makeEntry(journal: journal, amount: -75);
    final event = EntryDestroyed.fromEntry(entry);

    expect(event.entryId, entry.id);
    expect(event.snapshot.journalId, journal.id);
    expect(event.snapshot.assetId, journal.asset.id);
    expect(event.snapshot.amount, -75);
  });
}
