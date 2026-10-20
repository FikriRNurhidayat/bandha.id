import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  test("fromEntry captures journal, asset and amount", () {
    final asset = makeAsset();
    final journal = makeJournal(asset: asset);
    final snapshot = EntrySnapshot.fromEntry(
      makeEntry(journal: journal, amount: -42),
    );

    expect(snapshot.journalId, journal.id);
    expect(snapshot.assetId, asset.id);
    expect(snapshot.amount, -42);
  });
}
