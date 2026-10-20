import 'package:bandha/modules/assets/application/event_handlers/update_asset_balance_on_entry_updated.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/assets_classifiers_tools_fakes.dart';
import '../../../../support/fixtures.dart';

EntrySnapshot snap(String journalId, String assetId, double amount) =>
    EntrySnapshot(journalId: journalId, assetId: assetId, amount: amount);

void main() {
  group("UpdateAssetBalanceOnEntryUpdated", () {
    late FakeAssetRepository repository;
    late UpdateAssetBalanceOnEntryUpdated handler;

    setUp(() {
      repository = FakeAssetRepository(
        seed: [
          makeAsset(id: "a", balance: 100),
          makeAsset(id: "b", balance: 0),
        ],
      );
      handler = UpdateAssetBalanceOnEntryUpdated(repository);
    });

    test("does nothing without balance impact", () async {
      await handler.handle(
        EntryUpdated(
          entryId: "e",
          before: snap("j", "a", 10),
          after: snap("j", "a", 10),
        ),
      );

      expect(repository.increments, isEmpty);
    });

    test("applies the amount difference on the same asset", () async {
      await handler.handle(
        EntryUpdated(
          entryId: "e",
          before: snap("j", "a", 10),
          after: snap("j", "a", 25),
        ),
      );

      expect(repository.increments, [("a", -10.0), ("a", 25.0)]);
      expect(repository.store["a"]!.balance, 115);
    });

    test("moves the amount when the asset changes", () async {
      final event = EntryUpdated(
        entryId: "e",
        before: snap("j1", "a", 10),
        after: snap("j2", "b", 10),
      );
      expect(event.assetChanged, isTrue);

      await handler.handle(event);

      expect(repository.store["a"]!.balance, 90);
      expect(repository.store["b"]!.balance, 10);
    });

    test("journal change within the same asset nets to zero", () async {
      await handler.handle(
        EntryUpdated(
          entryId: "e",
          before: snap("j1", "a", 10),
          after: snap("j2", "a", 10),
        ),
      );

      expect(repository.increments.length, 2);
      expect(repository.store["a"]!.balance, 100);
    });

    test("works with events built from entries", () async {
      final asset = makeAsset(id: "a");
      final journal = makeJournal(asset: asset);
      final before = makeEntry(id: "e", amount: -5, journal: journal);
      final after = makeEntry(id: "e", amount: -8, journal: journal);

      await handler.handle(EntryUpdated.of(before, after));

      expect(repository.store["a"]!.balance, 97);
    });
  });
}
