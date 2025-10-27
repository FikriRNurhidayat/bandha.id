import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/pair.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

class EntryRepository extends Repository {
  EntryRepository._(super.db);

  static Future<EntryRepository> build() async {
    final db = await Repository.connect();
    return EntryRepository._(db);
  }

  Future<double> sum(Map? spec) async {
    final baseQuery = "SELECT SUM(amount) AS entries_amount FROM entries";
    final query = _makeQuery(baseQuery, spec);
    final rows = db.select(query.first, query.second);

    if (rows.isEmpty) {
      return 0;
    }

    return rows.first["entries_amount"] ?? 0;
  }

  Future<int> count(Map? spec) async {
    final baseQuery = "SELECT COUNT(*) AS entries_count FROM entries";
    final query = _makeQuery(baseQuery, spec);
    final rows = db.select(query.first, query.second);

    if (rows.isEmpty) {
      return 0;
    }

    return rows.first["entries_count"] ?? 0;
  }

  Future<Entry> create({
    required String note,
    required double amount,
    required EntryStatus status,
    required DateTime timestamp,
    required String accountId,
    required String categoryId,
    required List<String>? labelIds,
  }) async {
    final id = Repository.getId();
    final now = DateTime.now();

    return atomic<Entry>(() async {
      final category = await getCategoryById(categoryId);
      final account = await getAccountById(accountId);

      await insertEntry({
        "id": id,
        "note": note,
        "amount": amount,
        "timestamp": timestamp.toIso8601String(),
        "status": status.label,
        "readonly": 0,
        "category_id": categoryId,
        "account_id": accountId,
        "created_at": now.toIso8601String(),
        "updated_at": now.toIso8601String(),
      });

      await setEntityLabels(
        entityId: id,
        labelIds: labelIds,
        junctionKey: "entry_id",
        junctionTable: "entry_labels",
      );

      return Entry(
        id: id,
        note: note,
        amount: amount,
        timestamp: timestamp,
        status: status,
        readonly: false,
        categoryId: categoryId,
        categoryName: category!["name"],
        accountId: accountId,
        accountName: account!["name"],
        accountHolderName: account["holder_name"],
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  Future<void> update({
    required String id,
    required String note,
    required double amount,
    required EntryStatus status,
    required DateTime timestamp,
    required String categoryId,
    required String accountId,
    required List<String>? labelIds,
  }) async {
    final now = DateTime.now();

    return atomic(() async {
      final initEntry = await getEntryById(id);

      await updateEntry({
        "id": id,
        "note": note,
        "amount": amount,
        "status": status.label,
        "timestamp": timestamp.toIso8601String(),
        "category_id": categoryId,
        "account_id": accountId,
        "updated_at": now.toIso8601String(),
        "label_ids": labelIds,
      }, amount - initEntry["amount"]);

      await setEntityLabels(
        entityId: id,
        labelIds: labelIds,
        junctionKey: "entry_id",
        junctionTable: "entry_labels",
      );
    });
  }

  Future<Entry?> get(String id) async {
    final ResultSet entryRows = db.select(
      """
      SELECT
        entries.id,
        entries.note,
        entries.amount,
        entries.timestamp,
        entries.status,
        entries.readonly,
        entries.category_id,
        categories.name AS category_name,
        entries.account_id,
        accounts.name AS account_name,
        accounts.holder_name AS account_holder_name,
        entries.created_at,
        entries.updated_at
      FROM entries
      INNER JOIN categories ON categories.id = entries.category_id 
      INNER JOIN accounts ON accounts.id = entries.account_id 
      WHERE entries.id = ?
      """,
      [id],
    );

    return populate(entryRows).then((entries) => entries.firstOrNull);
  }

  Future<List<Entry>> search({Map? spec}) async {
    var baseQuery = """
        SELECT DISTINCT
          entries.id,
          entries.note,
          entries.amount,
          entries.timestamp,
          entries.status,
          entries.readonly,
          entries.category_id,
          categories.name AS category_name,
          entries.account_id,
          accounts.name AS account_name,
          accounts.holder_name AS account_holder_name,
          entries.created_at,
          entries.updated_at
        FROM entries
        INNER JOIN categories ON categories.id = entries.category_id 
        INNER JOIN accounts ON accounts.id = entries.account_id 
      """;

    final query = _makeQuery(baseQuery, spec);
    final sqlString = "${query.first} ORDER BY entries.timestamp DESC";
    final sqlArgs = query.second;

    final ResultSet entryRows = db.select(sqlString, sqlArgs);

    return populate(entryRows).catchError((error) => throw error);
  }

  Future<void> delete(String id) async {
    return atomic(() async {
      final entry = await getEntryById(id);

      await updateAccountBalance(entry["account_id"], entry["amount"] * -1);

      await resetEntityLabels(
        entityId: id,
        junctionTable: "entry_labels",
        junctionKey: "entry_id",
      );

      db.execute("DELETE FROM entries WHERE id = ?", [id]);
    });
  }

  Future<List<Entry>> populate(List<Map> entryRows) async {
    return populateLabels(entryRows, "entry_labels", "entry_id")
        .then(
          (entryRows) => entryRows
              .map(
                (entryRow) => Entry.fromRow(
                  entryRow,
                ).setLabels(Label.fromRows(entryRow["labels"])),
              )
              .toList(),
        )
        .catchError((error) => throw error);
  }

  Pair<String, List<dynamic>> _makeQuery(String baseQuery, Map? spec) {
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

    if (spec.containsKey("timestamp_between")) {
      final value = spec["timestamp_between"] as DateTimeRange;
      where["query"].add("(entries.timestamp BETWEEN ? AND ?)");
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
