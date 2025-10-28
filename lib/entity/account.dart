import 'package:banda/entity/entry.dart';

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
  double balance;
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

  Account applyEntry(EntryType type, double delta) {
    if (type == EntryType.income) {
      balance += delta;
    } else {
      balance -= delta;
    }

    return this;
  }

  Account revokeEntry(Entry entry) {
    balance -= entry.amount;
    return this;
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

  factory Account.fromRow(Map<dynamic, dynamic> row) {
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
}
