import 'package:banda/entity/controlable.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/types/controller.dart';

class LoanPayment extends Controlable {
  final String loanId;
  final String entryId;
  final double amount;
  final double? fee;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime issuedAt;

  late final Entry entry;
  late final Loan loan;

  LoanPayment({
    required this.loanId,
    required this.entryId,
    required this.amount,
    this.fee,
    required this.createdAt,
    required this.updatedAt,
    required this.issuedAt,
  });

  factory LoanPayment.create({
    required double amount,
    required double? fee,
    required String loanId,
    required String entryId,
    required DateTime issuedAt,
  }) {
    return LoanPayment(
      loanId: loanId,
      amount: amount,
      fee: fee,
      entryId: entryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      issuedAt: issuedAt,
    );
  }

  LoanPayment withEntry(Entry? value) {
    if (value == null) return this;
    entry = value;
    return this;
  }

  LoanPayment withLoan(Loan? value) {
    if (value == null) return this;
    loan = value;
    return this;
  }

  get accountId {
    return entry.accountId;
  }

  get account {
    return entry.account;
  }

  copyWith({double? amount, double? fee, DateTime? issuedAt}) {
    return LoanPayment(
      loanId: loanId,
      entryId: entryId,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      issuedAt: issuedAt ?? this.issuedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory LoanPayment.fromRow(Map row) {
    return LoanPayment(
      loanId: row["loan_id"],
      entryId: row["entry_id"],
      amount: row["amount"],
      fee: row["fee"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
      issuedAt: DateTime.parse(row["issued_at"]),
    );
  }

  @override
  Controller toController() {
    return Controller.loanPayment(loanId);
  }
}
