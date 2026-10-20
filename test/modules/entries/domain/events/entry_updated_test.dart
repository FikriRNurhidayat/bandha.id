import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

EntryUpdated updated(
  ({String journalId, String assetId, double amount}) before,
  ({String journalId, String assetId, double amount}) after,
) {
  return EntryUpdated(
    entryId: "e",
    before: EntrySnapshot(
      journalId: before.journalId,
      assetId: before.assetId,
      amount: before.amount,
    ),
    after: EntrySnapshot(
      journalId: after.journalId,
      assetId: after.assetId,
      amount: after.amount,
    ),
  );
}

void main() {
  test("of snapshots both sides", () {
    final j1 = makeJournal();
    final j2 = makeJournal();
    final before = makeEntry(journal: j1, amount: 10);
    final after = before.copyWith(amount: 20).withJournal(j2);
    final event = EntryUpdated.of(before, after);

    expect(event.entryId, before.id);
    expect(event.before.journalId, j1.id);
    expect(event.before.amount, 10);
    expect(event.after.journalId, j2.id);
    expect(event.after.assetId, j2.asset.id);
    expect(event.after.amount, 20);
  });

  test("no balance impact when nothing relevant changed", () {
    final event = updated(
      (journalId: "j", assetId: "a", amount: 1),
      (journalId: "j", assetId: "a", amount: 1),
    );

    expect(event.journalChanged, isFalse);
    expect(event.assetChanged, isFalse);
    expect(event.amountChanged, isFalse);
    expect(event.hasBalanceImpact, isFalse);
  });

  test("journal change has balance impact", () {
    final event = updated(
      (journalId: "j1", assetId: "a", amount: 1),
      (journalId: "j2", assetId: "a", amount: 1),
    );

    expect(event.journalChanged, isTrue);
    expect(event.assetChanged, isFalse);
    expect(event.amountChanged, isFalse);
    expect(event.hasBalanceImpact, isTrue);
  });

  test("asset change has balance impact", () {
    final event = updated(
      (journalId: "j", assetId: "a1", amount: 1),
      (journalId: "j", assetId: "a2", amount: 1),
    );

    expect(event.assetChanged, isTrue);
    expect(event.journalChanged, isFalse);
    expect(event.hasBalanceImpact, isTrue);
  });

  test("amount change has balance impact", () {
    final event = updated(
      (journalId: "j", assetId: "a", amount: 1),
      (journalId: "j", assetId: "a", amount: 2),
    );

    expect(event.amountChanged, isTrue);
    expect(event.hasBalanceImpact, isTrue);
  });
}
