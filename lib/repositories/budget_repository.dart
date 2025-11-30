import 'package:banda/entity/budget.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/pair.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

class BudgetRepository extends Repository {
  late WithArgs withArgs;

  BudgetRepository(super.db, {WithArgs? withArgs}) : withArgs = withArgs ?? {};

  static Future<BudgetRepository> build() async {
    final db = await Repository.connect();
    return BudgetRepository(db);
  }

  BudgetRepository withLabels() {
    withArgs.add("labels");
    return BudgetRepository(db, withArgs: withArgs);
  }

  BudgetRepository withCategory() {
    withArgs.add("category");
    return BudgetRepository(db, withArgs: withArgs);
  }

  snapshot(Budget budget) async {
    db.execute(
      'INSERT INTO budget_history (id, budget_id, usage, threshold, limit, start_at, end_at) VALUES (?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET budget_id = excluded.budget_id, usage = excluded.usage, threshold = excluded.threshold, limit = excluded.limit, start_at = excluded.start_at, end_at = excluded.end_at',
      [
        Repository.getId(),
        budget.id,
        budget.usage,
        budget.threshold,
        budget.limit,
        budget.startAt?.toIso8601String(),
        budget.endAt?.toIso8601String(),
      ],
    );
  }

  save(Budget budget) async {
    db.execute(
      'INSERT INTO budgets (id, note, usage, threshold, "limit", cycle, category_id, created_at, updated_at, issued_at, start_at, end_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET note = excluded.note, usage = excluded.usage, "limit" = excluded."limit", cycle = excluded.cycle, category_id = excluded.category_id, updated_at = excluded.updated_at, issued_at = excluded.issued_at, start_at = excluded.start_at, end_at = excluded.end_at',
      [
        budget.id,
        budget.note,
        budget.usage,
        budget.threshold,
        budget.limit,
        budget.cycle.label,
        budget.categoryId,
        budget.createdAt.toIso8601String(),
        budget.updatedAt.toIso8601String(),
        budget.issuedAt.toIso8601String(),
        budget.startAt?.toIso8601String(),
        budget.endAt?.toIso8601String(),
      ],
    );
  }

  delete(String id) async {
    db.execute("DELETE FROM budgets WHERE id = ?", [id]);
  }

  Future<Budget> get(String id) async {
    final rows = db.select("SELECT budgets.* FROM budgets WHERE id = ?", [id]);
    return entities(rows).then((budgets) => budgets.first);
  }

  Future<List<Budget>> search(Specification? spec) async {
    final query = defineQuery("SELECT budgets.* from budgets", spec);
    final rows = db.select(query.first, query.second);
    return entities(rows);
  }

  Future<Budget?> getExactly(
    String categoryId,
    DateTime issued,
    List<String>? labelIds,
  ) async {
    final hasLabels = labelIds != null && labelIds.isNotEmpty;
    final issuedStr = issued.toIso8601String();

    if (!hasLabels) {
      final rows = db.select(
        '''
      SELECT b.*
      FROM budgets b
      LEFT JOIN budget_labels bl ON bl.budget_id = b.id
      WHERE b.category_id = ?
        AND bl.label_id IS NULL
        AND ((b.cycle = ?) OR (? BETWEEN b.start_at AND b.end_at))
      ''',
        [categoryId, BudgetCycle.indefinite.label, issuedStr],
      );
      return entities(rows).then((b) => b.firstOrNull);
    }

    final placeholders = List.filled(labelIds.length, '?').join(',');
    final args = [
      categoryId,
      BudgetCycle.indefinite.label,
      issuedStr,
      labelIds.length,
      ...labelIds,
      labelIds.length,
    ];

    final rows = db.select('''
    SELECT b.*
    FROM budgets b
    JOIN budget_labels bl ON bl.budget_id = b.id
    WHERE b.category_id = ?
      AND ((b.cycle = ?) OR (? BETWEEN b.start_at AND b.end_at))
    GROUP BY b.id
    HAVING 
      COUNT(*) = ?
      AND SUM(bl.label_id IN ($placeholders)) = ?
    ''', args);

    return entities(rows).then((b) => b.firstOrNull);
  }

  setLabels(String id, List<String> labelIds) {
    return setEntityLabels(
      entityId: id,
      labelIds: labelIds,
      junctionTable: "budget_labels",
      junctionKey: "budget_id",
    );
  }

  defineQuery(String sqlQuery, Specification? spec) {
    if (spec == null) return Pair(sqlQuery, []);
    final sqlArgs = <dynamic>[];

    final join = joinQuery(spec);
    if (join.isNotEmpty) {
      sqlQuery += join;
    }

    final where = whereQuery(spec);
    if (where.first.isNotEmpty) {
      sqlQuery += "WHERE ${where.first}";
      sqlArgs.addAll(where.second);
    }

    return Pair(sqlQuery, sqlArgs);
  }

  Pair<String, List<dynamic>> whereQuery(Specification spec) {
    final whereExpr = <String>[];
    final whereArgs = <dynamic>[];

    if (spec.containsKey("category_in")) {
      final value = spec["category_in"] as List<String>;
      whereExpr.add("(budgets.category_id IN (${inExpr(value)}))");
      whereArgs.addAll(value);
    }

    if (spec.containsKey("label_in")) {
      final value = spec["label_in"] as List<String>;
      whereExpr.add("(budget_labels.label_in IN (${inExpr(value)}))");
      whereArgs.addAll(value);
    }

    if (spec.containsKey("cycle_in")) {
      final expr = spec["cycle_in"] as List<BudgetCycle>;
      final value = expr.map((v) => v.label).toList();
      whereExpr.add("(budgets.cycle IN (${inExpr(value)}))");
      whereArgs.addAll(value);
    }

    if (spec.containsKey("created_between")) {
      final expr = spec["created_between"] as DateTimeRange;
      whereExpr.add("(budgets.created_at BETWEEN ? AND ?)");
      whereArgs.addAll([expr.start, expr.end]);
    }

    if (spec.containsKey("issued_between")) {
      final expr = spec["issued_between"] as DateTimeRange;
      whereExpr.add("(budgets.issued_at BETWEEN ? AND ?)");
      whereArgs.addAll([expr.start, expr.end]);
    }

    return Pair(whereExpr.join(" AND "), whereArgs);
  }

  String joinQuery(Specification spec) {
    final joinExpr = <String>[];

    if (spec.containsKey("label_in")) {
      joinExpr.add(
        "INNER JOIN budget_labels ON budgets.id = budget_labels.budget_id",
      );
    }

    return joinExpr.join(" ");
  }

  Future<List<Budget>> entities(List<Map> rows) async {
    if (withArgs.contains("labels")) {
      rows = await populateLabels(rows);
    }
    if (withArgs.contains("category")) {
      rows = await populateCategory(rows);
    }

    return rows
        .map(
          (row) => Budget.row(row)
              .withCategory(Category.tryRow(row["category"]))
              .withLabels(Label.tryRows(row["labels"])),
        )
        .toList();
  }

  populateLabels(List<Map> rows) {
    return populateEntityLabels(rows, "budget_labels", "budget_id");
  }
}
