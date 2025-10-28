import 'package:banda/entity/account.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/pair.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

class EntryRepository extends Repository {
  Set<String> withOpts;

  EntryRepository(super.db, {Set<String>? withOpts})
    : withOpts = withOpts ?? {};

  static Future<EntryRepository> build() async {
    final db = await Repository.connect();
    return EntryRepository(db);
  }

  EntryRepository withLabels() {
    withOpts.add("labels");
    return EntryRepository(db, withOpts: withOpts);
  }

  EntryRepository withAccount() {
    withOpts.add("account");
    return EntryRepository(db, withOpts: withOpts);
  }

  EntryRepository withCategory() {
    withOpts.add("category");
    return EntryRepository(db, withOpts: withOpts);
  }

  Future<void> save(Entry entry) async {
    db.execute(
      "INSERT INTO entries (id, note, amount, readonly, status, category_id, account_id, issued_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET note = excluded.note, amount = excluded.amount, readonly = excluded.readonly, status = excluded.status, issued_at = excluded.issued_at, category_id = excluded.category_id, account_id = excluded.account_id, updated_at = excluded.updated_at",
      [
        entry.id,
        entry.note,
        entry.amount,
        entry.readonly ? 1 : 0,
        entry.status.label,
        entry.categoryId,
        entry.accountId,
        entry.issuedAt.toIso8601String(),
        entry.createdAt.toIso8601String(),
        entry.updatedAt.toIso8601String(),
      ],
    );
  }

  Future<double> sum(Map? spec) async {
    final baseQuery = "SELECT SUM(amount) AS entries_amount FROM entries";
    final query = makeQuery(baseQuery, spec);
    final rows = db.select(query.first, query.second);

    if (rows.isEmpty) {
      return 0;
    }

    return rows.first["entries_amount"] ?? 0;
  }

  Future<int> count(Map? spec) async {
    final baseQuery = "SELECT COUNT(*) AS entries_count FROM entries";
    final query = makeQuery(baseQuery, spec);
    final rows = db.select(query.first, query.second);

    if (rows.isEmpty) {
      return 0;
    }

    return rows.first["entries_count"] ?? 0;
  }

  setLabels(String entryId, List<String> labelIds) {
    return setEntityLabels(
      entityId: entryId,
      labelIds: labelIds,
      junctionTable: "entry_labels",
      junctionKey: "entry_id",
    );
  }

  Future<Entry?> get(String id) async {
    final ResultSet entryRows = db.select(
      "SELECT entries.* FROM entries WHERE id = ?",
      [id],
    );

    return populate(entryRows).then((entries) => entries.firstOrNull);
  }

  Future<List<Entry>> search({Map? spec}) async {
    var baseQuery = "SELECT entries.* FROM entries";

    final query = makeQuery(baseQuery, spec);
    final sqlString = "${query.first} ORDER BY entries.issued_at DESC";
    final sqlArgs = query.second;

    final ResultSet entryRows = db.select(sqlString, sqlArgs);

    return await populate(entryRows);
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM entries WHERE entries.id = ?", [id]);
  }

  populateEntryLabels(List<Map> rows) {
    return super.populateLabels(rows, "entry_labels", "entry_id");
  }

  Future<List<Entry>> populate(List<Map> entryRows) async {
    if (withOpts.contains("labels")) {
      entryRows = await populateEntryLabels(entryRows);
    }

    if (withOpts.contains("account")) {
      entryRows = await populateAccount(entryRows);
    }

    if (withOpts.contains("category")) {
      entryRows = await populateCategory(entryRows);
    }

    return entryRows.map((e) {
      return Entry.fromRow(e)
          .withLabels(Label.fromRows(e["labels"] ?? []))
          .withAccount(
            e["account"] != null ? Account.fromRow(e["account"]) : null,
          )
          .withCategory(
            e["category"] != null ? Category.fromRow(e["category"]) : null,
          );
    }).toList();
  }

  Pair<String, List<dynamic>> makeQuery(String baseQuery, Map? spec) {
    var args = <dynamic>[];

    final join = _join(spec);

    if (join != null && join["sql"].isNotEmpty) {
      baseQuery = "$baseQuery ${join["sql"]}";
    }

    final where = _where(spec);

    if (where != null && where["sql"].isNotEmpty) {
      baseQuery = "$baseQuery WHERE ${where["sql"]}";
      args = where["args"];
    }

    return Pair(baseQuery, args);
  }

  Map? _join(Map? spec) {
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

    if (spec.containsKey("saving_in")) {
      final value = spec["saving_in"] as List<String>;
      if (value.isNotEmpty) {
        join["query"].add(
          "INNER JOIN saving_entries ON saving_entries.entry_id = entries.id",
        );
      }
    }

    join["sql"] = join["query"].join(" ");

    return join;
  }

  Map? _where(Map? spec) {
    if (spec == null) return null;

    final Map<String, dynamic> where = {
      "args": <dynamic>[],
      "query": <String>[],
      "sql": null,
    };

    if (spec.containsKey("note_regex")) {
      final value = spec["note_regex"];
      if (value.isNotEmpty) {
        where["query"].add("REGEXP(?, entries.note)");
        where["args"].add(spec["note_regex"]);
      }
    }

    if (spec.containsKey("amount_lt")) {
      final value = spec["amount_lt"] as double;
      where["query"].add("entries.amount < ?");
      where["args"].add(value);
    }

    if (spec.containsKey("amount_lte")) {
      final value = spec["amount_lte"] as double;
      where["query"].add("entries.amount <= ?");
      where["args"].add(value);
    }

    if (spec.containsKey("amount_gt")) {
      final value = spec["amount_gt"] as double;
      where["query"].add("entries.amount > ?");
      where["args"].add(value);
    }

    if (spec.containsKey("amount_gte")) {
      final value = spec["amount_gte"] as double;
      where["query"].add("entries.amount >= ?");
      where["args"].add(value);
    }

    if (spec.containsKey("issued_at_between")) {
      final value = spec["issued_at_between"] as DateTimeRange;
      where["query"].add("(entries.issued_at BETWEEN ? AND ?)");
      where["args"].addAll([value.start, value.end]);
    }

    if (spec.containsKey("account_in")) {
      final value = spec["account_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(entries.account_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (spec.containsKey("status_in")) {
      final value = spec["status_in"] as List<EntryStatus>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(entries.status IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value.map((v) => v.label).toList());
      }
    }

    if (spec.containsKey("category_in")) {
      final value = spec["category_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(entries.category_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (spec.containsKey("category_id_ne")) {
      final value = spec["category_id_ne"] as String?;

      if (value != null && value.isNotEmpty) {
        where["query"].add("(entries.category_id != ?)");
        where["args"].add(value);
      }
    }

    if (spec.containsKey("label_in")) {
      final value = spec["label_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(entry_labels.label_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (spec.containsKey("saving_in")) {
      final value = spec["saving_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(saving_entries.saving_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    where["sql"] = where["query"].join(" AND ");
    return where;
  }
}
