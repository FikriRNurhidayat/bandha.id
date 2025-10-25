class Transfer {
  final String id;
  final String note;
  final double amount;
  final double? fee;
  final DateTime timestamp;
  final String fromAccountId;
  final String fromAccountName;
  final String fromAccountHolderName;
  final String toAccountId;
  final String toAccountName;
  final String toAccountHolderName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transfer({
    required this.id,
    required this.note,
    required this.amount,
    required this.fee,
    required this.timestamp,
    required this.fromAccountId,
    required this.fromAccountName,
    required this.fromAccountHolderName,
    required this.toAccountId,
    required this.toAccountName,
    required this.toAccountHolderName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transfer.fromRow(Map<dynamic, dynamic> row) {
    return Transfer(
      id: row["id"],
      note: row["note"],
      amount: row["amount"],
      fee: row["fee"],
      timestamp: DateTime.parse(row["timestamp"]),
      fromAccountId: row["from_account_id"],
      fromAccountName: row["from_account_name"],
      fromAccountHolderName: row["from_account_holder_name"],
      toAccountId: row["to_account_id"],
      toAccountName: row["to_account_name"],
      toAccountHolderName: row["to_account_holder_name"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }
}
