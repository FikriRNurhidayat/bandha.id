import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';

class Journal extends Controllable {
  @override
  final String id;
  final String name;
  final String holderName;
  final double balance;
  final String assetId;
  final DateTime createdAt;
  final DateTime updatedAt;

  late Asset asset;

  Journal({
    required this.id,
    required this.name,
    required this.holderName,
    required this.balance,
    required this.assetId,
    required this.createdAt,
    required this.updatedAt,
  });

  static Journal? tryRow(Map? row) {
    if (row == null) return null;
    return Journal.fromRow(row);
  }

  factory Journal.fromRow(Map row) {
    final journal = Journal(
      id: row["id"],
      name: row["name"],
      holderName: row["holder_name"],
      assetId: row["asset_id"],
      balance: row["balance"] ?? 0,
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );

    return journal;
  }

  factory Journal.create({
    required String name,
    required String holderName,
    required double balance,
    required String assetId,
  }) {
    final now = DateTime.now();

    return Journal(
      id: Entity.getId(),
      name: name,
      holderName: holderName,
      balance: balance,
      assetId: assetId,
      createdAt: now,
      updatedAt: now,
    );
  }

  Journal withAsset(Asset asset) {
    this.asset = asset;
    return this;
  }

  Journal copyWith({
    String? name,
    String? holderName,
    double? balance,
    String? assetId,
  }) {
    return Journal(
      id: id,
      name: name ?? this.name,
      holderName: holderName ?? this.holderName,
      balance: balance ?? this.balance,
      assetId: assetId ?? this.assetId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  String get displayName => "$name – $holderName";
}
