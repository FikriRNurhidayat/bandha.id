import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';

class Transfer extends Controllable {
  Transfer({
    required this.id,
    this.note,
    required this.creditId,
    this.creditFeeId,
    required this.debitId,
    this.debitFeeId,
    required this.issuedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transfer.create({
    String? note,
    required String creditId,
    String? creditFeeId,
    required String debitId,
    String? debitFeeId,
    required DateTime issuedAt,
  }) {
    final now = DateTime.now();

    return Transfer(
      id: Entity.getId(),
      note: note,
      creditId: creditId,
      creditFeeId: creditFeeId,
      debitId: debitId,
      debitFeeId: debitFeeId,
      issuedAt: issuedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Transfer.fromRow(Map row) {
    return Transfer(
      id: row["id"],
      note: row["note"],
      creditId: row["credit_id"],
      creditFeeId: row["credit_fee_id"],
      debitId: row["debit_id"],
      debitFeeId: row["debit_fee_id"],
      issuedAt: DateTime.parse(row["issued_at"]),
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }

  static Transfer? tryRow(Map? row) {
    if (row == null) return null;
    return Transfer.fromRow(row);
  }

  @override
  final String id;
  final String? note;
  final String creditId;
  String? creditFeeId;
  final String debitId;
  String? debitFeeId;
  final DateTime issuedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  late Entry credit;
  late Entry? creditFee;
  late Entry debit;
  late Entry? debitFee;

  Iterable<Entry> get entries {
    return [credit, creditFee, debit, debitFee].whereType<Entry>();
  }

  Iterable<String> get entryIds {
    return [creditId, creditFeeId, debitId, debitFeeId].whereType<String>();
  }

  Transfer clearCreditFee() {
    creditFeeId = null;
    return withCreditFee(null);
  }

  Transfer clearDebitFee() {
    debitFeeId = null;
    return withDebitFee(null);
  }

  Transfer copyWith({
    String? note,
    String? creditId,
    String? creditFeeId,
    String? debitId,
    String? debitFeeId,
    DateTime? issuedAt,
  }) {
    return Transfer(
          id: id,
          note: note ?? this.note,
          creditId: creditId ?? this.creditId,
          creditFeeId: creditFeeId ?? this.creditFeeId,
          debitId: debitId ?? this.debitId,
          debitFeeId: debitFeeId ?? this.debitFeeId,
          issuedAt: issuedAt ?? this.issuedAt,
          createdAt: createdAt,
          updatedAt: DateTime.now(),
        )
        .withDebit(debit)
        .withDebitFee(debitFee)
        .withCredit(credit)
        .withCreditFee(creditFee);
  }

  Transfer withCredit(Entry credit) {
    this.credit = credit;
    return this;
  }

  Transfer withCreditFee(Entry? creditFee) {
    creditFeeId = creditFee?.id;
    this.creditFee = creditFee;
    return this;
  }

  Transfer withDebit(Entry debit) {
    this.debit = debit;
    return this;
  }

  Transfer withDebitFee(Entry? debitFee) {
    debitFeeId = debitFee?.id;
    this.debitFee = debitFee;
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "note": note,
      "credit": credit.toJson(),
      "creditFee": creditFee?.toJson(),
      "creditFeeId": creditFeeId,
      "creditId": creditId,
      "debit": debit.toJson(),
      "debitFee": debitFee?.toJson(),
      "debitFeeId": debitFeeId,
      "debitId": debitId,
      "issuedAt": issuedAt.toIso8601String(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}
