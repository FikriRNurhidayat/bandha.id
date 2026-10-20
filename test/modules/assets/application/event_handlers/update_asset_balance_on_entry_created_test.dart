import 'package:bandha/modules/assets/application/event_handlers/update_asset_balance_on_entry_created.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fixtures.dart';

EntryCreated created(String assetId, double amount, {bool skip = false}) {
  return EntryCreated(
    entryId: "e",
    snapshot: EntrySnapshot(journalId: "j", assetId: assetId, amount: amount),
    skip: skip,
  );
}

void main() {
  group("UpdateAssetBalanceOnEntryCreated", () {
    late FakeAssetRepository repository;
    late UpdateAssetBalanceOnEntryCreated handler;

    setUp(() {
      repository = FakeAssetRepository(
        seed: [makeAsset(id: "a", balance: 100)],
      );
      handler = UpdateAssetBalanceOnEntryCreated(repository);
    });

    test("increments the asset by the entry amount", () async {
      await handler.handle(created("a", -30));

      expect(repository.increments, [("a", -30.0)]);
      expect(repository.store["a"]!.balance, 70);
    });

    test("uses the asset of the entry's journal", () async {
      final asset = makeAsset(id: "a");
      final entry = makeEntry(amount: 25, journal: makeJournal(asset: asset));

      await handler.handle(EntryCreated.fromEntry(entry));

      expect(repository.increments, [("a", 25.0)]);
    });

    test("still increments when skip is set", () async {
      // `skip` only tells the journal handler that the journal balance
      // already includes this amount; assets have no such pre-set balance.
      await handler.handle(created("a", 40, skip: true));

      expect(repository.store["a"]!.balance, 140);
    });

    test("handleAll applies every event", () async {
      await handler.handleAll([created("a", 10), created("a", 5)]);

      expect(repository.store["a"]!.balance, 115);
    });
  });
}
