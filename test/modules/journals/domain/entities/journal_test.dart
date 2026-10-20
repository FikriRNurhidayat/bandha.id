import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  final row = {
    "id": "j1",
    "name": "Wallet",
    "holder_name": "Me",
    "asset_id": "a1",
    "balance": 1500.0,
    "created_at": "2026-01-15T10:30:00.000Z",
    "updated_at": "2026-01-16T10:30:00.000Z",
  };

  group("fromRow", () {
    test("maps columns", () {
      final journal = Journal.fromRow(row);

      expect(journal.id, "j1");
      expect(journal.name, "Wallet");
      expect(journal.holderName, "Me");
      expect(journal.assetId, "a1");
      expect(journal.balance, 1500.0);
      expect(journal.createdAt, DateTime.utc(2026, 1, 15, 10, 30));
      expect(journal.updatedAt, DateTime.utc(2026, 1, 16, 10, 30));
    });

    test("defaults a null balance to zero", () {
      expect(Journal.fromRow({...row, "balance": null}).balance, 0);
    });

    test("tryRow handles null", () {
      expect(Journal.tryRow(null), isNull);
      expect(Journal.tryRow(row)?.id, "j1");
    });
  });

  test("create assigns a fresh id and timestamps", () {
    final a = Journal.create(
      name: "Bank",
      holderName: "You",
      balance: 10,
      assetId: "a",
    );
    final b = Journal.create(
      name: "Bank",
      holderName: "You",
      balance: 10,
      assetId: "a",
    );

    expect(a.id, isNot(b.id));
    expect(a.name, "Bank");
    expect(a.holderName, "You");
    expect(a.balance, 10);
    expect(a.assetId, "a");
    expect(a.createdAt, a.updatedAt);
  });

  test("copyWith keeps identity and overrides fields", () {
    final journal = makeJournal(name: "Old", balance: 5);
    final copy = journal.copyWith(
      name: "New",
      holderName: "Other",
      balance: 7,
      assetId: "a2",
    );

    expect(copy.id, journal.id);
    expect(copy, journal);
    expect(copy.name, "New");
    expect(copy.holderName, "Other");
    expect(copy.balance, 7);
    expect(copy.assetId, "a2");
    expect(copy.createdAt, journal.createdAt);
    expect(copy.updatedAt.isAfter(journal.updatedAt), isTrue);
  });

  test("copyWith without arguments keeps values", () {
    final journal = makeJournal(name: "Same", balance: 3);
    final copy = journal.copyWith();

    expect(copy.name, "Same");
    expect(copy.holderName, journal.holderName);
    expect(copy.balance, 3);
    expect(copy.assetId, journal.assetId);
  });

  test("displayName joins name and holder", () {
    expect(
      makeJournal(name: "BCA", holderName: "Fikri").displayName,
      "BCA – Fikri",
    );
  });

  test("controller identifies the journal", () {
    final journal = makeJournal();

    expect(journal.controller.id, journal.id);
    expect(journal.controller.type, "Journal");
    expect(journal.dataFilter, {
      "controller_id_eq": journal.id,
      "controller_type_eq": "Journal",
    });
  });

  test("toJson includes the asset", () {
    final asset = makeAsset();
    final journal = makeJournal(asset: asset, balance: 9);

    expect(journal.toJson(), {
      "id": journal.id,
      "name": "Wallet",
      "holderName": "Me",
      "asset": asset.toJson(),
      "assetId": asset.id,
      "balance": 9,
      "createdAt": fixedTime.toIso8601String(),
      "updatedAt": fixedTime.toIso8601String(),
    });
  });
}
