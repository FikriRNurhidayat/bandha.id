import 'package:bandha/modules/journals/domain/value_objects/journal_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  test("fromJournal captures name, holder, balance and asset", () {
    final journal = makeJournal(name: "N", holderName: "H", balance: 12);
    final snapshot = JournalSnapshot.fromJournal(journal);

    expect(snapshot.name, "N");
    expect(snapshot.holderName, "H");
    expect(snapshot.balance, 12);
    expect(snapshot.assetId, journal.assetId);
  });
}
