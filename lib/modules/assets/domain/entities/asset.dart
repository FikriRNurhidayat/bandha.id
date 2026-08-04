import 'package:bandha/core/domain/entities/controlable.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:flutter/foundation.dart';

class Asset extends Controllable {
  @override
  final String id;
  final String name;
  final String code;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Asset({
    required this.id,
    required this.name,
    required this.code,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName {
    return "$name ($code)";
  }

  static Asset? tryRow(Map? row) {
    if (row == null) return null;
    return Asset.fromRow(row);
  }

  factory Asset.fromRow(Map row) {
    return Asset(
      id: row["id"],
      name: row["name"],
      code: row["code"],
      balance: row["balance"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }

  factory Asset.create({required String name, required String code}) {
    final now = DateTime.now();
    return Asset(
      id: Entity.getId(),
      name: name,
      code: code,
      balance: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  Asset copyWith({String? name, String? code, double? balance}) {
    return Asset(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      balance: balance ?? this.balance,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "code": code,
      "balance": balance,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
