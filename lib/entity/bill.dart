import 'package:banda/entity/account.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entity.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';

enum BillCycle {
  oneTime('One Time'),
  monthly('Monthly'),
  yearly('Yearly');

  final String label;
  const BillCycle(this.label);
}

enum BillStatus {
  paid('Paid'),
  overdue('Overdue'),
  active('Active');

  final String label;
  const BillStatus(this.label);

  EntryStatus get entryStatus {
    switch (this) {
      case BillStatus.active:
      case BillStatus.overdue:
        return EntryStatus.pending;
      case BillStatus.paid:
        return EntryStatus.done;
    }
  }
}

class Bill extends Entity {
  final String id;
  final String note;
  final double amount;
  final BillCycle cycle;
  final BillStatus status;
  final String categoryId;
  final String accountId;
  final String entryId;
  final DateTime billedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  late List<Label> labels;
  late Account account;
  late Category category;
  late Entry entry;

  Bill({
    required this.id,
    required this.note,
    required this.amount,
    required this.cycle,
    required this.status,
    required this.categoryId,
    required this.accountId,
    required this.entryId,
    required this.billedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Bill withLabels(List<Label>? labels) {
    if (labels != null) this.labels = labels;
    return this;
  }

  Bill withAccount(Account? account) {
    if (account != null) this.account = account;
    return this;
  }

  Bill withCategory(Category? category) {
    if (category != null) this.category = category;
    return this;
  }

  Bill withEntry(Entry? entry) {
    if (entry != null) this.entry = entry;
    return this;
  }

  Bill copyWith({
    String? note,
    double? amount,
    BillCycle? cycle,
    BillStatus? status,
    String? categoryId,
    String? accountId,
    String? entryId,
    DateTime? billedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id,
      note: note ?? this.note,
      amount: amount ?? this.amount,
      cycle: cycle ?? this.cycle,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      entryId: entryId ?? this.entryId,
      billedAt: billedAt ?? this.billedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Bill.create({
    required String note,
    required double amount,
    required BillCycle cycle,
    required BillStatus status,
    required String categoryId,
    required String accountId,
    required String entryId,
    required DateTime billedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return Bill(
      id: Entity.getId(),
      note: note,
      amount: amount,
      cycle: cycle,
      status: status,
      categoryId: categoryId,
      accountId: accountId,
      billedAt: billedAt,
      entryId: entryId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static tryRow(Map? row) {
    if (row == null) return null;
    return Bill.row(row);
  }

  factory Bill.row(Map row) {
    return Bill(
      id: row["id"],
      note: row["note"],
      amount: row["amount"],
      cycle: BillCycle.values.firstWhere((v) => v.label == row["cycle"]),
      status: BillStatus.values.firstWhere((v) => v.label == row["status"]),
      categoryId: row["category_id"],
      accountId: row["account_id"],
      entryId: row["entry_id"],
      billedAt: DateTime.parse(row["billed_at"]),
      createdAt: DateTime.parse(row["updated_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }

  toMap() {
    return {
      "id": id,
      "note": note,
      "amount": amount,
      "cycle": cycle,
      "status": status,
      "categoryId": categoryId,
      "accountId": accountId,
      "entryId": entryId,
      "billedAt": billedAt,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }
}
