import 'package:banda/entity/category.dart';
import 'package:banda/entity/entity.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';

class Budget extends Entity {
  final String id;
  final String note;
  final double usage;
  final double limit;
  final BudgetCycle cycle;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? expiredAt;

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
    this.startedAt,
    this.expiredAt,
  });

  factory Budget.create({
    required String note,
    required double usage,
    required double limit,
    required BudgetCycle cycle,
    required String categoryId,
    DateTime? startedAt,
    DateTime? expiredAt,
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
      startedAt: startedAt,
      expiredAt: expiredAt,
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
      startedAt: DateTime.tryParse(row["started_at"] ?? ''),
      expiredAt: DateTime.tryParse(row["expired_at"] ?? ''),
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
      "startedAt": startedAt,
      "expiredAt": expiredAt,
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
    DateTime? expiredAt,
    DateTime? startedAt,
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
      expiredAt: expiredAt ?? this.expiredAt,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  Budget applyEntry(Entry entry) {
    return copyWith(usage: usage + entry.amount);
  }

  Budget revokeEntry(Entry entry) {
    return copyWith(usage: usage - entry.amount);
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
  specific('Specific'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  final String label;
  const BudgetCycle(this.label);
}
