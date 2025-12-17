import 'package:banda/common/entities/controlable.dart';
import 'package:banda/features/accounts/entities/account.dart';
import 'package:banda/features/entries/entities/entry.dart';
import 'package:banda/features/loans/entities/loan.dart';
import 'package:banda/common/types/controller.dart';

class LoanPayment extends Controlable {
  final String loanId;
  final String entryId;
  final String? additionId;
  final double amount;
  final double? fee;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime issuedAt;

  late final Entry? addition;
  late final Entry entry;
  late final Loan loan;

  LoanPayment({
    required this.loanId,
    required this.entryId,
    this.additionId,
    required this.amount,
    this.fee,
    required this.createdAt,
    required this.updatedAt,
    required this.issuedAt,
  });

  static double additionAmount(Loan loan, double? fee) {
    return (fee ?? 0) * -1;
  }

  static String additionNote(Loan loan) {
    if (loan.type.isDebt()) {
      return loan.status.isSettled()
          ? "Debt settlement fee"
          : "Debt payment fee";
    }

    return loan.status.isSettled()
        ? "Receivable settlement fee"
        : "Receivable payment fee";
  }

  static double entryAmount(Loan loan, double amount) {
    return amount * (loan.type.isDebt() ? -1 : 1);
  }

  static String entryNote(Loan loan) {
    if (loan.type.isDebt()) {
      return loan.status.isSettled()
          ? "Debt settlement to ${loan.party.name}"
          : "Debt payment to ${loan.party.name}";
    }

    return loan.status.isSettled()
        ? "Receivable settlement from ${loan.party.name}"
        : "Receivable payment from ${loan.party.name}";
  }

  factory LoanPayment.create({
    required double amount,
    double? fee,
    required String loanId,
    required String entryId,
    String? additionId,
    required DateTime issuedAt,
  }) {
    return LoanPayment(
      loanId: loanId,
      amount: amount,
      fee: fee,
      entryId: entryId,
      additionId: additionId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      issuedAt: issuedAt,
    );
  }

  LoanPayment withAddition(Entry? value) {
    if (value == null) return this;
    addition = value;
    return this;
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

  String get accountId {
    return entry.accountId;
  }

  Account get account {
    return entry.account;
  }

  List<Entry?> get entries {
    return [entry, addition];
  }

  bool get hasAddition {
    return addition != null;
  }

  LoanPayment copyWith({double? amount, double? fee, DateTime? issuedAt}) {
    return LoanPayment(
      loanId: loanId,
      entryId: entryId,
      additionId: additionId,
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
      additionId: row["addition_id"],
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
