import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fixtures.dart';

void main() {
  group("Asset.create", () {
    test("starts with zero balance and equal timestamps", () {
      final asset = Asset.create(name: "Rupiah", code: "IDR");

      expect(asset.id, isNotEmpty);
      expect(asset.name, "Rupiah");
      expect(asset.code, "IDR");
      expect(asset.balance, 0);
      expect(asset.createdAt, asset.updatedAt);
    });

    test("generates unique ids", () {
      final a = Asset.create(name: "A", code: "A");
      final b = Asset.create(name: "A", code: "A");

      expect(a.id, isNot(b.id));
    });
  });

  group("Asset.fromRow", () {
    final row = {
      "id": "asset-1",
      "name": "Dollar",
      "code": "USD",
      "balance": 12.5,
      "created_at": "2026-01-15T10:30:00.000Z",
      "updated_at": "2026-01-16T10:30:00.000Z",
    };

    test("maps snake_case columns", () {
      final asset = Asset.fromRow(row);

      expect(asset.id, "asset-1");
      expect(asset.name, "Dollar");
      expect(asset.code, "USD");
      expect(asset.balance, 12.5);
      expect(asset.createdAt, DateTime.utc(2026, 1, 15, 10, 30));
      expect(asset.updatedAt, DateTime.utc(2026, 1, 16, 10, 30));
    });

    test("tryRow returns null for null and an asset otherwise", () {
      expect(Asset.tryRow(null), isNull);
      expect(Asset.tryRow(row)?.id, "asset-1");
    });
  });

  group("Asset.copyWith", () {
    test("overrides given fields and keeps identity", () {
      final asset = makeAsset(name: "Rupiah", code: "IDR", balance: 10);
      final copy = asset.copyWith(name: "Rp", balance: 20);

      expect(copy.id, asset.id);
      expect(copy.name, "Rp");
      expect(copy.code, "IDR");
      expect(copy.balance, 20);
      expect(copy.createdAt, fixedTime);
      expect(copy.updatedAt.isAfter(fixedTime), isTrue);
      expect(copy, asset);
    });

    test("keeps all fields when nothing is given", () {
      final asset = makeAsset(balance: 5);
      final copy = asset.copyWith();

      expect(copy.name, asset.name);
      expect(copy.code, asset.code);
      expect(copy.balance, 5);
    });
  });

  group("serialization", () {
    test("toJson uses ISO timestamps", () {
      final asset = makeAsset(id: "a", balance: 3);

      expect(asset.toJson(), {
        "id": "a",
        "name": "Rupiah",
        "code": "IDR",
        "balance": 3.0,
        "createdAt": fixedTime.toIso8601String(),
        "updatedAt": fixedTime.toIso8601String(),
      });
    });

    test("toMap keeps DateTime values", () {
      final map = makeAsset(id: "a").toMap();

      expect(map["id"], "a");
      expect(map["createdAt"], fixedTime);
      expect(map["updatedAt"], fixedTime);
    });

    test("toJson round-trips through fromRow", () {
      final asset = makeAsset(balance: 7);
      final json = asset.toJson();
      final restored = Asset.fromRow({
        "id": json["id"],
        "name": json["name"],
        "code": json["code"],
        "balance": json["balance"],
        "created_at": json["createdAt"],
        "updated_at": json["updatedAt"],
      });

      expect(restored.id, asset.id);
      expect(restored.balance, 7);
      expect(restored.createdAt, asset.createdAt);
    });
  });

  test("displayName joins name and code", () {
    expect(makeAsset(name: "Rupiah", code: "IDR").displayName, "Rupiah – IDR");
  });

  group("Controllable", () {
    test("controller identifies the asset", () {
      final asset = makeAsset(id: "a");
      final Controller controller = asset.controller;

      expect(controller.id, "a");
      expect(controller.type, "Asset");
      expect(asset.toController().toJson(), controller.toJson());
    });

    test("dataFilter targets the controller", () {
      expect(makeAsset(id: "a").dataFilter, {
        "controller_id_eq": "a",
        "controller_type_eq": "Asset",
      });
    });
  });
}
