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
  final double? balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    required this.id,
    required this.name,
    required this.holderName,
    required this.kind,
    required this.createdAt,
    required this.updatedAt,
    this.balance,
  });

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
