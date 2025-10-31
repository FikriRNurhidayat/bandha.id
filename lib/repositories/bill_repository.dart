import 'package:banda/entity/account.dart';
import 'package:banda/entity/bill.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/pair.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

class BillRepository extends Repository {
  final WithArgs withArgs;

  BillRepository(super.db, {WithArgs? withArgs}) : withArgs = withArgs ?? {};

  BillRepository withLabels() {
    withArgs.add("labels");
    return BillRepository(db, withArgs: withArgs);
  }

  BillRepository withAccount() {
    withArgs.add("account");
    return BillRepository(db, withArgs: withArgs);
  }

  BillRepository withCategory() {
    withArgs.add("category");
    return BillRepository(db, withArgs: withArgs);
  }

  BillRepository withEntry() {
    withArgs.add("entry");
    return BillRepository(db, withArgs: withArgs);
  }

  save(Bill bill) async {
    db.execute(
      "INSERT INTO bills (id, note, amount, cycle, status, category_id, account_id, billed_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET  note = excluded.note, amount = excluded.amount, cycle = excluded.cycle, status = excluded.status, category_id = excluded.category_id, account_id = excluded.account_id, billed_at = excluded.billed_at, updated_at = excluded.updated_at",
      [
        bill.id,
        bill.note,
        bill.amount,
        bill.cycle.label,
        bill.status.label,
        bill.categoryId,
        bill.accountId,
        bill.billedAt.toIso8601String(),
        bill.createdAt.toIso8601String(),
        bill.updatedAt.toIso8601String(),
      ],
    );
  }

  get(String id) async {
    final rows = db.select("SELECT * FROM bills WHERE id = ?", [id]);
    return entities(rows).then((bills) => bills.first);
  }

  delete(String id) async {
    db.execute("DELETE FROM bills WHERE id = ?", [id]);
  }

  search(Specification? specification) async {
    final sqlResult = defineQuery("SELECT * FROM bills", specification);
    final rows = db.select(sqlResult.first, sqlResult.second);
    return entities(rows).then((bills) => bills.toList());
  }

  setLabels(String billId, List<String> labelIds) async {
    await setEntityLabels(
      entityId: billId,
      labelIds: labelIds,
      junctionTable: "bill_labels",
      junctionKey: "bill_id",
    );
  }

  addEntry(Bill bill, Entry entry) async {
    db.execute("INSERT INTO bill_entries (bill_id, entry_id) VALUES (?, ?)", [
      bill.id,
      entry.id,
    ]);
  }

  removeEntry(Bill bill, Entry entry) async {
    db.execute("DELETE FROM bill_entries WHERE bill_id = ? AND entry_id = ?", [
      bill.id,
      entry.id,
    ]);
  }

  populateBillLabels(List<Map> rows) {
    return super.populateEntityLabels(rows, "bill_labels", "bill_id");
  }

  entities(List<Map> rows) async {
    if (withArgs.contains("labels")) {
      rows = await populateBillLabels(rows);
    }

    if (withArgs.contains("account")) {
      rows = await populateAccount(rows);
    }

    if (withArgs.contains("category")) {
      rows = await populateCategory(rows);
    }

    if (withArgs.contains("entry")) {
      final entryIds = rows.map((row) => row["entry_id"] as String).toList();
      final entryRows = await getEntryByIds(entryIds);
      rows = rows.map((row) {
        row["entry"] = entryRows.firstWhere(
          (entryRow) => entryRow["id"] == row["entry_id"],
        );
        return row;
      }).toList();
    }

    return rows
        .map(
          (row) => Bill.row(row)
              .withEntry(Entry.row(row["entry"]))
              .withLabels(Label.rows(row["labels"]))
              .withCategory(Category.row(row["category"]))
              .withAccount(Account.row(row["account"])),
        )
        .toList();
  }

  defineQuery(String sqlString, Specification? specification) {
    if (specification == null) return Pair(sqlString, []);
    final sqlArgs = [];

    final joinResult = joinQuery(specification);
    if (joinResult != null) {
      sqlString = "$sqlString ${joinResult.first}";
    }

    final whereResult = whereQuery(specification);
    if (whereResult != null) {
      sqlString = "$sqlString WHERE ${whereResult.first}";
      sqlArgs.addAll(whereResult.second);
    }

    return Pair(sqlString, sqlArgs);
  }

  joinQuery(Specification specification) {
    var joinExpr = <String>[];

    if (specification.containsKey("label_in")) {
      joinExpr.add("INNER JOIN bill_labels ON bill_labels.bill_id = bills.id");
    }

    return Pair(joinExpr.join(" "), []);
  }

  whereQuery(Specification specification) {
    var whereExpr = <String>[];
    var whereArgs = <dynamic>[];

    if (specification.containsKey("in")) {
      final v = specification["in"] as List<String>;
      whereExpr.add("(bills.id IN (${v.map((_) => "?").join(", ")}))");
      whereArgs.addAll(v);
    }

    if (specification.containsKey("category_in")) {
      final v = specification["category_in"] as List<String>;
      whereExpr.add("(bills.category_id IN (${v.map((_) => "?").join(", ")}))");
      whereArgs.addAll(v);
    }

    if (specification.containsKey("label_in")) {
      final v = specification["label_in"] as List<String>;
      whereExpr.add(
        "(bill_labels.label_id IN (${v.map((_) => "?").join(", ")}))",
      );
      whereArgs.addAll(v);
    }

    if (specification.containsKey("account_in")) {
      final v = specification["account_in"] as List<String>;
      whereExpr.add("(bills.account_id IN (${v.map((_) => "?").join(", ")}))");
      whereArgs.addAll(v);
    }

    if (specification.containsKey("status_in")) {
      final v = specification["status_in"] as List<BillStatus>;
      whereExpr.add("(bills.status IN (${v.map((_) => "?").join(", ")}))");
      whereArgs.addAll(v.map((v) => v.label));
    }

    if (specification.containsKey("cycle_in")) {
      final v = specification["cycle_in"] as List<BillCycle>;
      whereExpr.add("(bills.cycle IN (${v.map((_) => "?").join(", ")}))");
      whereArgs.addAll(v.map((v) => v.label));
    }

    if (specification.containsKey("billed_between")) {
      final v = specification["billed_between"] as DateTimeRange;
      whereExpr.add("(bills.billed_at BETWEEN ? AND ?)");
      whereArgs.addAll([v.start.toIso8601String(), v.end.toIso8601String()]);
    }

    if (specification.containsKey("created_between")) {
      final v = specification["created_between"] as DateTimeRange;
      whereExpr.add("(bills.created_at BETWEEN ? AND ?)");
      whereArgs.addAll([v.start.toIso8601String(), v.end.toIso8601String()]);
    }

    if (specification.containsKey("updated_between")) {
      final v = specification["updated_between"] as DateTimeRange;
      whereExpr.add("(bills.updated_at BETWEEN ? AND ?)");
      whereArgs.addAll([v.start.toIso8601String(), v.end.toIso8601String()]);
    }

    if (whereExpr.isEmpty) return null;

    return Pair(whereExpr.join(" AND "), whereArgs);
  }
}
