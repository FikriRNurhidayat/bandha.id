import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

class EntryRepository extends Repository {
  EntryRepository._(super.db);

  static Future<EntryRepository> build() async {
    final db = await Repository.connect();
    return EntryRepository._(db);
  }

  Future<double> sum(Map? spec) async {
    var select = "SELECT SUM(amount) AS entries_amount FROM entries";
    var args = <dynamic>[];

    final join = _join(spec);
    if (join != null && join["sql"].isNotEmpty) {
      select = "$select ${join["sql"]}";
    }

    select = "$select WHERE deleted_at IS NULL";

    final where = _where(spec);
    if (where != null && where["sql"].isNotEmpty) {
      select = "$select AND ${where["sql"]}";
      args = where["args"];
    }

    final rows = db.select(select, args);

    if (rows.isEmpty) {
      return 0;
    }

    return rows.first["entries_amount"] ?? 0;
  }

  Future<int> count(Map? spec) async {
    try {
      var select = "SELECT COUNT(*) AS entries_count FROM entries";
      var args = <dynamic>[];

      final join = _join(spec);
      if (join != null && join["sql"].isNotEmpty) {
        select = "$select ${join["sql"]}";
      }

      select = "$select WHERE deleted_at IS NULL";

      final where = _where(spec);
      if (where != null && where["sql"].isNotEmpty) {
        select = "$select AND ${where["sql"]}";
        args = where["args"];
      }

      final rows = db.select(select, args);

      if (rows.isEmpty) {
        return 0;
      }

      return rows.first["entries_count"];
    } catch (error) {
      rethrow;
    }
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

    try {
      db.execute("BEGIN TRANSACTION");

      final category = await _getCategory(categoryId);
      if (category == null) {
        throw UnimplementedError();
      }

      final account = await _getAccount(accountId);
      if (account == null) {
        throw UnimplementedError();
      }

      db.execute(
        "INSERT INTO entries (id, note, amount, timestamp, status, readonly, category_id, account_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          id,
          note,
          amount,
          timestamp.toIso8601String(),
          status.label,
          0,
          category["id"],
          account["id"],
          now.toIso8601String(),
          now.toIso8601String(),
        ],
      );

      _insertLabels(id, labelIds);

      db.execute("COMMIT");

      return Entry(
        id: id,
        note: note,
        amount: amount,
        timestamp: timestamp,
        status: status,
        readonly: false,
        categoryId: categoryId,
        categoryName: category["name"],
        accountId: accountId,
        accountName: account["name"],
        accountHolderName: account["holder_name"],
        createdAt: now,
        updatedAt: now,
      );
    } catch (error) {
      db.execute("ROLLBACK");
      rethrow;
    }
  }

  Future<Entry?> update({
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

    try {
      db.execute("BEGIN TRANSACTION");

      db.execute(
        "UPDATE entries SET note = ?, amount = ?, status = ?, timestamp = ?, category_id = ?, account_id = ?, updated_at = ? WHERE id = ?",
        [
          note,
          amount,
          status.label,
          timestamp.toIso8601String(),
          categoryId,
          accountId,
          now.toIso8601String(),
          id,
        ],
      );

      _insertLabels(id, labelIds);

      db.execute("COMMIT");

      return get(id);
    } catch (error) {
      db.execute("ROLLBACK");

      rethrow;
    }
  }

  Future<Entry?> get(String id) async {
    final ResultSet rows = db.select(
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

    if (rows.isEmpty) {
      return null;
    }

    final labelRows = _getEntryLabelRows([rows.first["id"]]);
    final entryRow = Map.from(rows.first);

    entryRow["labels"] =
        labelRows
            ?.where((labelRow) => labelRow["entry_id"] == entryRow["id"])
            .map((labelRow) => Label.fromRow(labelRow))
            .toList() ??
        [];
    return Entry.fromRow(entryRow);
  }

  Future<List<Entry>> search({Map? spec}) async {
    var select = """
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

    var args = <dynamic>[];

    final join = _join(spec);

    if (join != null && join["sql"].isNotEmpty) {
      select = "$select ${join["sql"]}";
    }

    final where = _where(spec);

    if (where != null && where["sql"].isNotEmpty) {
      select = "$select WHERE ${where["sql"]}";
      args = where["args"];
    }

    select = "$select ORDER BY entries.timestamp DESC";

    final ResultSet entryRows = db.select(select, args);
    final List<String> entryIds = entryRows
        .map((row) => row["id"] as String)
        .toList();

    final labelRows = _getEntryLabelRows(entryIds);

    return entryRows.map((row) {
      final entryRow = Map.from(row);
      entryRow["labels"] =
          labelRows
              ?.where((labelRow) => labelRow["entry_id"] == entryRow["id"])
              .map((labelRow) => Label.fromRow(labelRow))
              .toList() ??
          [];
      return Entry.fromRow(entryRow);
    }).toList();
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM entries WHERE id = ?", [id]);
  }

  Future<Map?> _getCategory(String id) async {
    final ResultSet rows = db.select("SELECT * FROM categories WHERE id = ?", [
      id,
    ]);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<Map?> _getAccount(String id) async {
    final ResultSet rows = db.select("SELECT * FROM accounts WHERE id = ?", [
      id,
    ]);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Map? _join(Map? spec) {
    if (spec == null) return null;

    final Map<String, dynamic> join = {"query": <String>[], "sql": null};

    if (spec.containsKey("label_id_in")) {
      final value = spec["label_id_in"] as List<String>;
      if (value.isNotEmpty) {
        join["query"].add(
          "INNER JOIN entry_labels ON entry_labels.entry_id = entries.id",
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

    if (spec.containsKey("account_id_in")) {
      final value = spec["account_id_in"] as List<String>;
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

    if (spec.containsKey("category_id_in")) {
      final value = spec["category_id_in"] as List<String>;
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

    if (spec.containsKey("label_id_in")) {
      final value = spec["label_id_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(entry_labels.label_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    where["sql"] = where["query"].join(" AND ");
    return where;
  }

  void _insertLabels(String entryId, List<String>? labelIds) {
    if (labelIds == null) return;

    final now = DateTime.now().toIso8601String();

    db.execute("DELETE FROM entry_labels WHERE entry_labels.entry_id = ?", [
      entryId,
    ]);

    final labelRows = _getLabels(labelIds);
    final labelRowIds = labelRows.map((i) => i["id"]).toList();
    for (var labelId in labelRowIds) {
      db.execute(
        "INSERT INTO entry_labels (entry_id, label_id, created_at, updated_at) VALUES (?, ?, ?, ?)",
        [entryId, labelId, now, now],
      );
    }
  }

  ResultSet _getLabels(List<String>? ids) {
    if (ids == null) return [] as ResultSet;

    final idsPlaceholder = ids.map((_) => "?").join(", ");
    final labelsQuery =
        """
      SELECT labels.* FROM labels WHERE labels.id IN ($idsPlaceholder)
    """;

    final ResultSet rows = db.select(labelsQuery, ids);
    return rows;
  }

  ResultSet? _getEntryLabelRows(List<String>? ids) {
    if (ids == null) return null;

    final idsPlaceholder = ids.map((_) => "?").join(", ");
    final labelsQuery =
        """
      SELECT labels.*, entry_labels.entry_id FROM labels
      INNER JOIN entry_labels ON entry_labels.label_id = labels.id
      WHERE entry_labels.entry_id IN ($idsPlaceholder)
    """;

    final ResultSet rows = db.select(labelsQuery, ids);

    if (rows.isEmpty) return null;

    return rows;
  }
}
