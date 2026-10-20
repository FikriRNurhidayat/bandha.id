import 'package:bandha/modules/journals/data/services/journal_hydrator.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/entries_journals_fakes.dart';
import '../../../../support/fixtures.dart';

Journal bareJournal(String id, String assetId) {
  return Journal(
    id: id,
    name: "Wallet",
    holderName: "Me",
    balance: 0,
    assetId: assetId,
    createdAt: fixedTime,
    updatedAt: fixedTime,
  );
}

void main() {
  final a1 = makeAsset(code: "IDR");
  final a2 = makeAsset(code: "USD");

  test("attaches assets to each journal", () async {
    final hydrator = JournalHydrator(assetProvider: FakeAssetReader([a1, a2]));

    final result = (await hydrator.hydrateAll([
      bareJournal("j1", a1.id),
      bareJournal("j2", a2.id),
    ])).toList();

    expect(result[0].asset, a1);
    expect(result[1].asset, a2);
  });

  test("hydrate returns the single hydrated journal", () async {
    final hydrator = JournalHydrator(assetProvider: FakeAssetReader([a1]));

    final journal = await hydrator.hydrate(bareJournal("j1", a1.id));

    expect(journal.id, "j1");
    expect(journal.asset, a1);
  });

  test("fails when the asset cannot be resolved", () async {
    final hydrator = JournalHydrator(assetProvider: FakeAssetReader());

    await expectLater(
      hydrator.hydrate(bareJournal("j1", "missing")),
      throwsA(isA<TypeError>()),
    );
  });
}
