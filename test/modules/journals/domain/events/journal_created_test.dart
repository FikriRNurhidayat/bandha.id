import 'package:bandha/modules/journals/domain/events/journal_created.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  test("fromJournal snapshots the journal", () {
    final journal = makeJournal(balance: 100);
    final event = JournalCreated.fromJournal(journal);

    expect(event.journalId, journal.id);
    expect(event.snapshot.balance, 100);
    expect(event.snapshot.assetId, journal.assetId);
  });
}
