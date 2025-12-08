import 'package:banda/entity/account.dart';
import 'package:banda/entity/controlable.dart';
import 'package:banda/entity/entity.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/types/controller.dart';

class Transfer extends Controlable {
  final String id;
  final String note;
  final double amount;
  final double? fee;
  final String debitId;
  final String debitAccountId;
  final String creditId;
  final String creditAccountId;
  final DateTime issuedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  late final Entry debit;
  late final Account debitAccount;
  late final Account creditAccount;
  late final Entry credit;

  Transfer({
    required this.id,
    required this.note,
    required this.amount,
    required this.fee,
    required this.debitId,
    required this.debitAccountId,
    required this.creditId,
    required this.creditAccountId,
    required this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  toMap() {
    return {
      "id": id,
      "note": note,
      "amount": amount,
      "fee": fee,
      "debitId": debitId,
      "debitAccountId": debitAccountId,
      "creditId": creditId,
      "creditAccountId": creditAccountId,
      "issuedAt": issuedAt,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  static Transfer? tryRow(Map<dynamic, dynamic>? row) {
    if (row == null) return null;
    return Transfer.fromRow(row);
  }

  factory Transfer.fromRow(Map<dynamic, dynamic> row) {
    return Transfer(
      id: row["id"],
      note: row["note"],
      amount: row["amount"],
      fee: row["fee"],
      debitId: row["debit_id"],
      debitAccountId: row["debit_account_id"],
      creditId: row["credit_id"],
      creditAccountId: row["credit_account_id"],
      issuedAt: DateTime.parse(row["issued_at"]),
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }

  factory Transfer.create({
    required String note,
    required double amount,
    required double? fee,
    required String debitId,
    required String debitAccountId,
    required String creditId,
    required String creditAccountId,
    required DateTime issuedAt,
  }) {
    return Transfer(
      id: Entity.getId(),
      note: note,
      amount: amount,
      fee: fee,
      debitId: debitId,
      debitAccountId: debitAccountId,
      creditId: creditId,
      creditAccountId: creditAccountId,
      issuedAt: issuedAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Transfer withDebit(Entry? value) {
    if (value != null) debit = value;
    return this;
  }

  Transfer withCredit(Entry? value) {
    if (value != null) credit = value;
    return this;
  }

  Transfer withDebitAccount(Account? value) {
    if (value != null) debitAccount = value;
    return this;
  }

  Transfer withCreditAccount(Account? value) {
    if (value != null) creditAccount = value;
    return this;
  }

  Transfer copyWith({
    String? note,
    double? amount,
    double? fee,
    String? debitId,
    String? debitAccountId,
    String? creditId,
    String? creditAccountId,
    DateTime? issuedAt,
  }) {
    return Transfer(
      id: id,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      debitId: debitId ?? this.debitId,
      debitAccountId: debitAccountId ?? this.debitAccountId,
      creditId: creditId ?? this.creditId,
      creditAccountId: creditAccountId ?? this.creditAccountId,
      issuedAt: issuedAt ?? this.issuedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Controller toController() {
    return Controller.transfer(id);
  }
}
