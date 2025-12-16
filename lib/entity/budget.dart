import 'package:banda/entity/category.dart';
import 'package:banda/common/entities/entity.dart';
import 'package:banda/features/entries/entities/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/helpers/date_helper.dart';

class Budget extends Entity {
  final String id;
  final String note;
  final double usage;
  final double threshold;
  final double limit;
  final BudgetCycle cycle;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime issuedAt;
  final DateTime? startAt;
  final DateTime? endAt;

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

  get labelIds {
    return labels.map((label) => label.id).toList();
  }

  Budget({
    required this.id,
    required this.note,
    required this.usage,
    required this.threshold,
    required this.limit,
    required this.cycle,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.issuedAt,
    this.startAt,
    this.endAt,
  });

  factory Budget.create({
    required String note,
    required double usage,
    required double threshold,
    required double limit,
    required BudgetCycle cycle,
    required String categoryId,
    required DateTime issuedAt,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return Budget(
      id: Entity.getId(),
      note: note,
      usage: usage,
      threshold: threshold,
      limit: limit,
      cycle: cycle,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      issuedAt: issuedAt,
      startAt: startAt,
      endAt: endAt,
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
      threshold: row["threshold"],
      limit: row["limit"],
      cycle: BudgetCycle.values.firstWhere((v) => v.label == row["cycle"]),
      categoryId: row["category_id"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
      issuedAt: DateTime.parse(row["issued_at"] ?? ''),
      startAt: DateTime.tryParse(row["start_at"] ?? ''),
      endAt: DateTime.tryParse(row["end_at"] ?? ''),
    );
  }

  toMap() {
    return {
      "id": id,
      "note": note,
      "usage": usage,
      "threshold": threshold,
      "limit": limit,
      "cycle": cycle,
      "categoryId": categoryId,
      "labelIds": labels.map((label) => label.id).toList(),
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "issuedAt": issuedAt,
      "startAt": startAt,
      "endAt": endAt,
    };
  }

  Budget copyWith({
    String? id,
    String? note,
    double? usage,
    double? threshold,
    double? limit,
    BudgetCycle? cycle,
    String? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? issuedAt,
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return Budget(
      id: id ?? this.id,
      note: note ?? this.note,
      usage: usage ?? this.usage,
      threshold: threshold ?? this.threshold,
      limit: limit ?? this.limit,
      cycle: cycle ?? this.cycle,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      issuedAt: issuedAt ?? this.issuedAt,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
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

  isModified() {
    return limit != threshold;
  }

  get remainder {
    return limit - usage;
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

  isDefinite() {
    return this != BudgetCycle.indefinite;
  }

  isDaily() {
    return this == BudgetCycle.daily;
  }

  isMonthly() {
    return this == BudgetCycle.monthly;
  }

  isYearly() {
    return this == BudgetCycle.yearly;
  }

  start(DateTime issued) {
    if (this == BudgetCycle.indefinite) return null;
    return issued;
  }

  end(DateTime issued) {
    final start = this.start(issued);

    switch (this) {
      case BudgetCycle.daily:
        return start.add(Duration(days: 1));
      case BudgetCycle.weekly:
        return start.add(Duration(days: 7));
      case BudgetCycle.monthly:
        return DateHelper.addMonths(start, 1);
      case BudgetCycle.yearly:
        return DateHelper.addYears(start, 1);
      case BudgetCycle.indefinite:
        return null;
    }
  }
}
