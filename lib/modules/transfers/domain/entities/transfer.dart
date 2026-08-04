import 'package:bandha/core/domain/entities/controlable.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';

class Transfer extends Controllable {
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

  Transfer withDebit(Entry debit) {
    this.debit = debit;
    return this;
  }

  Transfer withCredit(Entry credit) {
    this.credit = credit;
    return this;
  }

  Transfer withDebitFee(Entry? debitFee) {
    debitFeeId = debitFee?.id;
    this.debitFee = debitFee;
    return this;
  }

  Transfer clearDebitFee() {
    debitFeeId = null;
    return withDebitFee(null);
  }

  Transfer withCreditFee(Entry? creditFee) {
    creditFeeId = creditFee?.id;
    this.creditFee = creditFee;
    return this;
  }

  Transfer clearCreditFee() {
    creditFeeId = null;
    return withCreditFee(null);
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

  Iterable<String> get entryIds {
    return [creditId, creditFeeId, debitId, debitFeeId].whereType<String>();
  }

  Iterable<Entry> get entries {
    return [credit, creditFee, debit, debitFee].whereType<Entry>();
  }
}
