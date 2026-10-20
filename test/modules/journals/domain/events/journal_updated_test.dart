import 'package:bandha/modules/journals/domain/events/journal_updated.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  test("of snapshots before and after", () {
    final before = makeJournal(name: "A", balance: 100);
    final after = before.copyWith(name: "B");
    final event = JournalUpdated.of(before, after);

    expect(event.journalId, before.id);
    expect(event.before.name, "A");
    expect(event.after.name, "B");
    expect(event.balanceChanged, isFalse);
    expect(event.deltaAmount, 0);
  });

  test("reports balance change and delta", () {
    final before = makeJournal(balance: 100);

    final up = JournalUpdated.of(before, before.copyWith(balance: 150));
    expect(up.balanceChanged, isTrue);
    expect(up.deltaAmount, 50);

    final down = JournalUpdated.of(before, before.copyWith(balance: 40));
    expect(down.balanceChanged, isTrue);
    expect(down.deltaAmount, -60);
  });
}
