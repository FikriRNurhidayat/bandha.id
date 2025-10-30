import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/repositories/repository.dart';

class Loan {
  final String id;
  final LoanKind kind;
  final LoanStatus status;
  final double amount;
  final double? fee;
  final String partyId;
  final String debitId;
  final String creditId;
  final String debitAccountId;
  final String creditAccountId;
  final DateTime issuedAt;
  final DateTime settledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  late final Party? party;
  late final Account? debitAccount;
  late final Account? creditAccount;
  late final Entry? debit;
  late final Entry? credit;

  Loan({
    required this.id,
    required this.kind,
    required this.status,
    required this.amount,
    this.fee,
    required this.partyId,
    required this.debitId,
    required this.debitAccountId,
    required this.creditId,
    required this.creditAccountId,
    required this.issuedAt,
    required this.settledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Loan withDebitAccount(Account? value) {
    debitAccount = value;
    return this;
  }

  Loan withCreditAccount(Account? value) {
    creditAccount = value;
    return this;
  }

  Loan withParty(Party? value) {
    party = value;
    return this;
  }

  Loan withDebit(Entry? value) {
    debit = value;
    return this;
  }

  Loan withCredit(Entry? value) {
    credit = value;
    return this;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "kind": kind,
      "status": status,
      "amount": amount,
      "fee": fee,
      "partyId": partyId,
      "debitId": debitId,
      "creditId": creditId,
      "debitAccountId": debitAccountId,
      "creditAccountId": creditAccountId,
      "issuedAt": issuedAt,
      "settledAt": settledAt,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  Loan copyWith({
    LoanKind? kind,
    LoanStatus? status,
    double? amount,
    double? fee,
    String? partyId,
    String? debitId,
    String? creditId,
    String? debitAccountId,
    String? creditAccountId,
    DateTime? issuedAt,
    DateTime? settledAt,
  }) {
    return Loan(
      id: id,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      partyId: partyId ?? this.partyId,
      debitId: debitId ?? this.debitId,
      creditId: creditId ?? this.creditId,
      debitAccountId: debitAccountId ?? this.debitAccountId,
      creditAccountId: creditAccountId ?? this.creditAccountId,
      issuedAt: issuedAt ?? this.issuedAt,
      settledAt: settledAt ?? this.settledAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory Loan.create({
    required LoanKind kind,
    required LoanStatus status,
    required double amount,
    required double? fee,
    required String partyId,
    required String debitId,
    required String creditId,
    required String debitAccountId,
    required String creditAccountId,
    required DateTime issuedAt,
    required DateTime settledAt,
  }) {
    return Loan(
      id: Repository.getId(),
      kind: kind,
      status: status,
      amount: amount,
      fee: fee,
      partyId: partyId,
      debitId: debitId,
      creditId: creditId,
      debitAccountId: debitAccountId,
      creditAccountId: creditAccountId,
      issuedAt: issuedAt,
      settledAt: settledAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory Loan.fromRow(Map<dynamic, dynamic> row) {
    return Loan(
      id: row["id"],
      kind: LoanKind.values.firstWhere((e) => e.label == row["kind"]),
      status: LoanStatus.values.firstWhere((e) => e.label == row["status"]),
      amount: row["amount"],
      fee: row["fee"],
      partyId: row["party_id"],
      creditId: row["credit_id"],
      debitId: row["debit_id"],
      debitAccountId: row["debit_account_id"],
      creditAccountId: row["credit_account_id"],
      issuedAt: DateTime.parse(row["issued_at"]),
      settledAt: DateTime.parse(row["settled_at"]),
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }
}

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
