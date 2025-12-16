import 'package:banda/common/entities/entity.dart';
import 'package:banda/features/entries/entities/entry.dart';

enum AccountKind {
  bankAccount('Bank Account'),
  ewallet('E-Wallet'),
  cash('Cash');

  final String label;
  const AccountKind(this.label);
}

class Account {
  final String id;
  final String name;
  final String holderName;
  final AccountKind kind;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    required this.id,
    required this.name,
    required this.holderName,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
    required this.balance,
  });

  Account copyWith({
    String? id,
    String? name,
    String? holderName,
    AccountKind? kind,
    double? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      holderName: holderName ?? this.holderName,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      balance: balance ?? this.balance,
    );
  }

  Account applyAmount(double amount) {
    return copyWith(balance: balance + amount);
  }

  Account applyDelta(EntryType type, double delta) {
    return copyWith(
      balance: type == EntryType.income ? balance + delta : balance - delta,
    );
  }

  Account applyEntry(Entry entry) {
    return copyWith(balance: balance + entry.amount);
  }

  Account applyEntries(List<Entry?> entries) {
    double newBalance = balance;

    for (var entry in entries) {
      if (entry == null) continue;

      newBalance += entry.amount;
    }

    return copyWith(balance: newBalance);
  }

  Account revokeEntries(List<Entry?> entries) {
    double newBalance = balance;

    for (var entry in entries) {
      if (entry == null) continue;

      newBalance -= entry.amount;
    }

    return copyWith(balance: newBalance);
  }

  Account revokeEntry(Entry entry) {
    return copyWith(balance: balance - entry.amount);
  }

  displayName() {
    return "$name — $holderName";
  }

  toMap() {
    return {
      "id": id,
      "name": name,
      "holderName": holderName,
      "kind": kind,
      "balance": balance,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  static Account? tryRow(Map<dynamic, dynamic>? row) {
    if (row == null) return null;
    return Account.row(row);
  }

  factory Account.row(Map<dynamic, dynamic> row) {
    return Account(
      id: row["id"],
      name: row["name"],
      holderName: row["holder_name"],
      kind: AccountKind.values.firstWhere((e) => e.label == row["kind"]),
      balance: row["balance"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }

  factory Account.create({
    required String name,
    required String holderName,
    required AccountKind kind,
    required double balance,
  }) {
    return Account(
      id: Entity.getId(),
      name: name,
      holderName: holderName,
      kind: kind,
      balance: balance,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
