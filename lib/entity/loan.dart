import 'package:banda/entity/account.dart';
import 'package:banda/entity/controlable.dart';
import 'package:banda/entity/entity.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan_payment.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/helpers/type_helper.dart';
import 'package:banda/types/controller.dart';

class Loan extends Controlable {
  final String id;
  final LoanType type;
  final LoanStatus status;
  final double amount;
  final double? fee;
  final double remainder;
  final String partyId;
  final String accountId;
  final String entryId;
  final DateTime issuedAt;
  final DateTime? settledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  late final Party party;
  late final Entry entry;
  late final Account account;

  Loan({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    this.fee,
    required this.remainder,
    required this.partyId,
    required this.entryId,
    required this.accountId,
    required this.issuedAt,
    this.settledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Loan withEntry(Entry? value) {
    if (value != null) entry = value;
    return this;
  }

  Loan withAccount(Account? value) {
    if (value != null) account = value;
    return this;
  }

  Loan withParty(Party? value) {
    if (value != null) party = value;
    return this;
  }

  Loan applyPayment(LoanPayment payment) {
    final newRemainder = remainder - payment.amount;

    return copyWith(
      remainder: newRemainder,
      status: newRemainder <= 0 ? LoanStatus.settled : status,
    );
  }

  Loan revokePayment(LoanPayment payment) {
    final newRemainder = remainder + payment.amount;

    return copyWith(
      remainder: newRemainder,
      status: newRemainder <= 0 ? LoanStatus.settled : status,
    );
  }

  double get paid {
    return amount - remainder;
  }

  double get completion {
    return (paid / amount);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type,
      "status": status,
      "amount": amount,
      "fee": fee,
      "partyId": partyId,
      "accountId": accountId,
      "entryId": entryId,
      "issuedAt": issuedAt,
      "settledAt": settledAt,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  Loan copyWith({
    LoanType? type,
    LoanStatus? status,
    double? amount,
    double? fee,
    double? remainder,
    String? partyId,
    String? accountId,
    String? entryId,
    DateTime? issuedAt,
    DateTime? settledAt,
  }) {
    return Loan(
      id: id,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      remainder: remainder ?? this.remainder,
      partyId: partyId ?? this.partyId,
      accountId: accountId ?? this.accountId,
      entryId: entryId ?? this.entryId,
      issuedAt: issuedAt ?? this.issuedAt,
      settledAt: settledAt ?? this.settledAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory Loan.create({
    required LoanType type,
    required LoanStatus status,
    required double amount,
    required double? fee,
    double? remainder,
    required String partyId,
    required String accountId,
    required String entryId,
    required DateTime issuedAt,
    DateTime? settledAt,
  }) {
    return Loan(
      id: Entity.getId(),
      type: type,
      status: status,
      amount: amount,
      fee: fee,
      remainder: remainder ?? amount,
      partyId: partyId,
      accountId: accountId,
      entryId: entryId,
      issuedAt: issuedAt,
      settledAt: settledAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Controller toController() {
    return Controller.loan(id);
  }

  static Loan? tryParse(Map<dynamic, dynamic>? row) {
    if (isNull(row)) return null;
    return Loan.parse(row!);
  }

  factory Loan.parse(Map<dynamic, dynamic> row) {
    return Loan(
      id: row["id"],
      type: LoanType.values.firstWhere((e) => e.label == row["kind"]),
      status: LoanStatus.values.firstWhere((e) => e.label == row["status"]),
      amount: row["amount"],
      fee: row["fee"],
      remainder: row["remainder"],
      partyId: row["party_id"],
      accountId: row["account_id"],
      entryId: row["entry_id"],
      issuedAt: DateTime.parse(row["issued_at"]),
      settledAt: DateTime.tryParse(row["settled_at"] ?? ""),
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }
}

enum LoanType {
  debt('Debt'),
  receiveable('Receivable');

  isDebt() {
    return this == LoanType.debt;
  }

  isReceiveable() {
    return this == LoanType.receiveable;
  }

  final String label;
  const LoanType(this.label);
}

enum LoanStatus {
  overdue('Overdue'),
  settled('Settled'),
  active('Active');

  final String label;
  const LoanStatus(this.label);

  isSettled() {
    return this == LoanStatus.settled;
  }

  get entryStatus {
    switch (this) {
      case LoanStatus.settled:
        return EntryStatus.done;
      case LoanStatus.overdue:
      case LoanStatus.active:
        return EntryStatus.pending;
    }
  }
}
