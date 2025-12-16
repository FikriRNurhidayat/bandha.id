import 'package:banda/features/accounts/entities/account.dart';
import 'package:banda/features/tags/entities/category.dart';
import 'package:banda/features/entries/entities/entry.dart';
import 'package:banda/features/tags/entities/label.dart';
import 'package:banda/common/repositories/repository.dart';
import 'package:banda/common/types/pair.dart';
import 'package:banda/common/types/specification.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

class EntryRepository extends Repository {
  WithArgs withArgs;

  EntryRepository(super.db, {WithArgs? withArgs}) : withArgs = withArgs ?? {};

  static Future<EntryRepository> build() async {
    final db = await Repository.connect();
    return EntryRepository(db);
  }

  EntryRepository withLabels() {
    withArgs.add("labels");
    return EntryRepository(db, withArgs: withArgs);
  }

  EntryRepository withAccount() {
    withArgs.add("account");
    return EntryRepository(db, withArgs: withArgs);
  }

  EntryRepository withCategory() {
    withArgs.add("category");
    return EntryRepository(db, withArgs: withArgs);
  }

  save(Entry entry) async {
    db.execute(
      "INSERT INTO entries (id, note, amount, readonly, status, category_id, account_id, controller_id, controller_type, issued_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET note = excluded.note, amount = excluded.amount, readonly = excluded.readonly, status = excluded.status, issued_at = excluded.issued_at, category_id = excluded.category_id, account_id = excluded.account_id, controller_id = excluded.controller_id, controller_type = excluded.controller_type, updated_at = excluded.updated_at",
      [
        entry.id,
        entry.note,
        entry.amount,
        entry.readonly ? 1 : 0,
        entry.status.label,
        entry.categoryId,
        entry.accountId,
        entry.controller?.id,
        entry.controller?.type.label,
        entry.issuedAt.toIso8601String(),
        entry.createdAt.toIso8601String(),
        entry.updatedAt.toIso8601String(),
      ],
    );

    if (entry.annotations.isNotEmpty) setAnnotations(entry);
  }

  setAnnotations(Entry entry) {
    final annotations = entry.annotations;
    final arguments = entry.annotations
        .map(
          (annotation) => [
            annotation.entryId,
            annotation.name.name,
            annotation.value,
          ],
        )
        .expand((i) => i)
        .toList();

    db.execute(
      "INSERT INTO entry_annotations (entry_id, name, value) VALUES ${annotations.map((_) => "(?, ?, ?)").join(", ")} ON CONFLICT (entry_id, name) DO UPDATE SET value = excluded.value",
      arguments,
    );
  }

  setLabels(String entryId, List<String> labelIds) {
    return setEntityLabels(
      entityId: entryId,
      labelIds: labelIds,
      junctionTable: "entry_labels",
      junctionKey: "entry_id",
    );
  }

  removeLabels(Entry entry) async {
    return resetEntityLabels(
      entityId: entry.id,
      junctionTable: "entry_labels",
      junctionKey: "entry_id",
    );
  }

  Future<Entry> get(String id) async {
    final ResultSet entryRows = db.select(
      "SELECT entries.* FROM entries WHERE id = ?",
      [id],
    );

    return entities(entryRows).then((entries) => entries.first);
  }

  Future<List<Entry>> search(Filter? specification) async {
    var baseQuery = "SELECT entries.* FROM entries";

    final query = defineQuery(baseQuery, specification);
    final sqlString = "${query.first} ORDER BY entries.issued_at DESC";
    final sqlArgs = query.second;

    final ResultSet entryRows = db.select(sqlString, sqlArgs);

    return await entities(entryRows);
  }

  delete(String id) async {
    db.execute("DELETE FROM entries WHERE entries.id = ?", [id]);
  }

  populateLabels(List<Map> rows) {
    return super.populateEntityLabels(rows, "entry_labels", "entry_id");
  }

  Future<List<Entry>> entities(List<Map> entryRows) async {
    if (withArgs.contains("labels")) {
      entryRows = await populateLabels(entryRows);
    }

    if (withArgs.contains("account")) {
      entryRows = await populateAccount(entryRows);
    }

    if (withArgs.contains("category")) {
      entryRows = await populateCategory(entryRows);
    }

    return entryRows.map((e) {
      return Entry.row(e)
          .withLabels(Label.tryRows(e["labels"]))
          .withAccount(Account.tryRow(e["account"]))
          .withCategory(Category.tryRow(e["category"]));
    }).toList();
  }

  defineQuery(String baseQuery, Map? spec) {
    var args = <dynamic>[];

    final join = joinQuery(spec);
    if (join != null && join["sql"].isNotEmpty) {
      baseQuery = "$baseQuery ${join["sql"]}";
    }

    final where = whereQuery(spec);
    if (where != null && where["sql"].isNotEmpty) {
      baseQuery = "$baseQuery WHERE ${where["sql"]}";
      args = where["args"];
    }

    return Pair(baseQuery, args);
  }

  joinQuery(Map? spec) {
    if (spec == null) return null;

    final Map<String, dynamic> join = {"query": <String>[], "sql": null};

    if (spec.containsKey("label_in")) {
      final value = spec["label_in"] as List<String>;
      if (value.isNotEmpty) {
        join["query"].add(
          "INNER JOIN entry_labels ON entry_labels.entry_id = entries.id",
        );
      }
    }

    if (spec.containsKey("fund_in")) {
      final value = spec["fund_in"] as List<String>;
      if (value.isNotEmpty) {
        join["query"].add(
          "INNER JOIN fund_transactions ON fund_transactions.entry_id = entries.id",
        );
      }
    }

    join["sql"] = join["query"].join(" ");

    return join;
  }

  whereQuery(Map? filter) {
    if (filter == null) return null;

    final Map<String, dynamic> where = {
      "args": <dynamic>[],
      "query": <String>[],
      "sql": null,
    };

    if (filter.containsKey("note_regex")) {
      final value = filter["note_regex"];
      if (value.isNotEmpty) {
        where["query"].add("REGEXP(?, entries.note)");
        where["args"].add(filter["note_regex"]);
      }
    }

    if (filter.containsKey("amount_lt")) {
      final value = filter["amount_lt"] as double;
      where["query"].add("entries.amount < ?");
      where["args"].add(value);
    }

    if (filter.containsKey("amount_lte")) {
      final value = filter["amount_lte"] as double;
      where["query"].add("entries.amount <= ?");
      where["args"].add(value);
    }

    if (filter.containsKey("amount_gt")) {
      final value = filter["amount_gt"] as double;
      where["query"].add("entries.amount > ?");
      where["args"].add(value);
    }

    if (filter.containsKey("amount_gte")) {
      final value = filter["amount_gte"] as double;
      where["query"].add("entries.amount >= ?");
      where["args"].add(value);
    }

    if (filter.containsKey("issued_between")) {
      final value = filter["issued_between"] as DateTimeRange;
      where["query"].add("(entries.issued_at BETWEEN ? AND ?)");
      where["args"].addAll([
        value.start.toIso8601String(),
        value.end.toIso8601String(),
      ]);
    }

    if (filter.containsKey("account_in")) {
      final value = filter["account_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(entries.account_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (filter.containsKey("status_in")) {
      final value = filter["status_in"] as List<EntryStatus>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(entries.status IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value.map((v) => v.label).toList());
      }
    }

    if (filter.containsKey("category_in")) {
      final value = filter["category_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(entries.category_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (filter.containsKey("category_ne")) {
      final value = filter["category_ne"] as String?;

      if (value != null && value.isNotEmpty) {
        where["query"].add("(entries.category_id != ?)");
        where["args"].add(value);
      }
    }

    if (filter.containsKey("label_in")) {
      final value = filter["label_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(entry_labels.label_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (filter.containsKey("fund_in")) {
      final value = filter["fund_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(fund_transactions.fund_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (filter.containsKey("controller_id_is")) {
      final value = filter["controller_id_is"] as String?;
      if (value != null) {
        where["query"].add("(entries.controller_id = ?)");
        where["args"].add(value);
      }
    }

    if (filter.containsKey("controller_type_is")) {
      final value = filter["controller_type_is"] as String?;
      if (value != null) {
        where["query"].add("(entries.controller_type = ?)");
        where["args"].add(value);
      }
    }

    where["sql"] = where["query"].join(" AND ");
    return where;
  }
}
