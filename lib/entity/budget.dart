import 'package:banda/entity/category.dart';
import 'package:banda/entity/entity.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/helpers/date_helper.dart';

class Budget extends Entity {
  final String id;
  final String note;
  final double usage;
  final double limit;
  final BudgetCycle cycle;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime issuedAt;
  final DateTime? resetAt;

  late Category category;
  late List<Label> labels;

  Budget withCategory(Category? value) {
    if (value != null) category = value;
    return this;
  }

  Budget withLabels(List<Label>? value) {
    if (value != null) labels = value;
    return this;
  }

  Budget({
    required this.id,
    required this.note,
    required this.usage,
    required this.limit,
    required this.cycle,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.issuedAt,
    this.resetAt,
  });

  factory Budget.create({
    required String note,
    required double usage,
    required double limit,
    required BudgetCycle cycle,
    required String categoryId,
    required DateTime issuedAt,
    DateTime? resetAt,
  }) {
    return Budget(
      id: Entity.getId(),
      note: note,
      usage: usage,
      limit: limit,
      cycle: cycle,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      issuedAt: issuedAt,
      resetAt: resetAt,
    );
  }

  static tryRow(Map? row) {
    if (row == null) return null;
    return Budget.row(row);
  }

  factory Budget.row(Map row) {
    return Budget(
      id: row["id"],
      note: row["note"],
      usage: row["usage"],
      limit: row["limit"],
      cycle: BudgetCycle.values.firstWhere((v) => v.label == row["cycle"]),
      categoryId: row["category_id"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
      issuedAt: DateTime.parse(row["issued_at"] ?? ''),
      resetAt: DateTime.tryParse(row["reset_at"] ?? ''),
    );
  }

  toMap() {
    return {
      "id": id,
      "note": note,
      "usage": usage,
      "limit": limit,
      "cycle": cycle,
      "categoryId": categoryId,
      "labelIds": labels.map((label) => label.id).toList(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "issuedAt": issuedAt,
      "resetAt": resetAt,
    };
  }

  Budget copyWith({
    String? id,
    String? note,
    double? usage,
    double? limit,
    BudgetCycle? cycle,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? issuedAt,
    DateTime? resetAt,
  }) {
    return Budget(
      id: id ?? this.id,
      note: note ?? this.note,
      usage: usage ?? this.usage,
      limit: limit ?? this.limit,
      cycle: cycle ?? this.cycle,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      issuedAt: issuedAt ?? this.issuedAt,
      resetAt: resetAt ?? this.resetAt,
    );
  }

  Budget applyEntry(Entry entry) {
    return copyWith(usage: usage + entry.amount.abs());
  }

  Budget revokeEntry(Entry entry) {
    return copyWith(usage: usage - entry.amount.abs());
  }

  getProgress() {
    return (usage / limit);
  }

  isOver() {
    return usage > limit;
  }

  isOkay() {
    return usage == limit;
  }

  isUnder() {
    return usage < limit;
  }
}

enum BudgetCycle {
  indefinite('Indefinite'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  final String label;
  const BudgetCycle(this.label);

  reset(DateTime issued) {
    switch (this) {
      case BudgetCycle.daily:
        return issued.add(Duration(days: 1));
      case BudgetCycle.weekly:
        return issued.add(Duration(days: 7));
      case BudgetCycle.monthly:
        return DateHelper.addMonths(issued, 1);
      case BudgetCycle.yearly:
        return DateHelper.addYears(issued, 1);
      case BudgetCycle.indefinite:
        return null;
    }
  }
}
