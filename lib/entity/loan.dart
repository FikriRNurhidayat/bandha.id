import 'package:banda/entity/entry.dart';

enum LoanKind {
  debt('Debt'),
  receiveable('Receivable');

  final String label;
  const LoanKind(this.label);
}

enum LoanStatus {
  overdue('Overdue'),
  settled('Settled'),
  active('Active');

  final String label;
  const LoanStatus(this.label);

  EntryStatus entryStatus() {
    switch (this) {
      case LoanStatus.settled:
        return EntryStatus.done;
      case LoanStatus.overdue:
      case LoanStatus.active:
        return EntryStatus.pending;
    }
  }
}

class Loan {
  final String id;
  final LoanKind kind;
  final LoanStatus status;
  final double amount;
  final double? fee;
  final String partyId;
  final String accountId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Loan({
    required this.id,
    required this.kind,
    required this.status,
    required this.amount,
    this.fee,
    required this.partyId,
    required this.accountId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Loan.fromRow(Map<dynamic, dynamic> row) {
    return Loan(
      id: row["id"],
      kind: LoanKind.values.firstWhere((e) => e.label == row["kind"]),
      status: LoanStatus.values.firstWhere((e) => e.label == row["status"]),
      amount: row["amount"],
      fee: row["fee"],
      partyId: row["party_id"],
      accountId: row["account_id"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }
}
