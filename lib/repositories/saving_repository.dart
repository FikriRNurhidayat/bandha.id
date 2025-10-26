import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:sqlite3/sqlite3.dart';

class SavingRepository extends Repository {
  SavingRepository._(super.db);

  static Future<SavingRepository> build() async {
    final db = await Repository.connect();
    return SavingRepository._(db);
  }

  Future<void> updateSavingEntry({
    required String id,
    required Saving saving,
    required double amount,
    required TransactionType type,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    final now = DateTime.now();

    return transaction(() async {
      final readonlyLabelIds = saving.labels!.map((label) => label.id).toList();
      final savingRow = Map.from((await _getSavingById(saving.id))!);
      final entry = Map.from((await getEntryById(id))!);

      entry["note"] = type == TransactionType.deposit
          ? "Deposit to ${saving.note}"
          : "Withdraw from ${saving.note}";
      entry["amount"] = type == TransactionType.deposit ? amount * -1 : amount;
      entry["timestamp"] = issuedAt.toIso8601String();

      await _createEntryLabels(
        entryId: entry["id"],
        now: now,
        readonlyLabelIds: readonlyLabelIds,
        writeableLabelIds:
            labelIds
                ?.where((labelId) => !readonlyLabelIds.contains(labelId))
                .toList() ??
            [],
      );

      savingRow["balance"] += type == TransactionType.deposit
          ? amount
          : amount * -1;

      await _updateSaving(savingRow);
      await updateEntry(entry);
    });
  }

  Future<void> createSavingEntry({
    required Saving saving,
    required double amount,
    required TransactionType type,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) {
    final now = DateTime.now();

    return transaction(() async {
      final readonlyLabelIds = saving.labels!.map((label) => label.id).toList();

      final savingRow = Map.from((await _getSavingById(saving.id))!);

      final entry = await _createEntry(
        saving: saving,
        type: type,
        amount: amount,
        issuedAt: issuedAt,
        now: now,
      );

      await _createEntryLabels(
        entryId: entry["id"],
        now: now,
        readonlyLabelIds: readonlyLabelIds,
        writeableLabelIds:
            labelIds
                ?.where((labelId) => !readonlyLabelIds.contains(labelId))
                .toList() ??
            [],
      );

      savingRow["balance"] += type == TransactionType.deposit
          ? amount
          : amount * -1;

      await _updateSaving(savingRow);

      db.execute(
        "INSERT INTO saving_entries (saving_id, entry_id) VALUES (?, ?)",
        [saving.id, entry["id"]],
      );
    });
  }

  Future<List<Saving>> search(Map? spec) async {
    var select = "SELECT * FROM savings";
    var args = <dynamic>[];
    final where = _where(spec);
    if (where != null && where["sql"].isNotEmpty) {
      select = "$select WHERE ${where["sql"]}";
      args = where["args"];
    }
    final savingRows = db.select("$select ORDER BY created_at DESC", args);

    return _populate(savingRows);
  }

  Future<Saving?> get(String id) async {
    final savingRows = db.select("SELECT * FROM savings WHERE id = ?", [id]);
    return (await _populate(savingRows)).firstOrNull;
  }

  Future<Saving> create({
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    final id = Repository.getId();
    final now = DateTime.now();
    return transaction<Saving>(() async {
      final saving = {
        "id": id,
        "note": note,
        "goal": goal,
        "balance": 0,
        "account_id": accountId,
        "created_at": now.toIso8601String(),
        "updated_at": now.toIso8601String(),
        "deleted_at": null,
      };

      if (labelIds != null) {
        _createLabels(id: id, labelIds: labelIds);
      }

      await _createSaving(saving);

      return Saving(
        id: id,
        note: note,
        goal: goal,
        balance: 0,
        accountId: accountId,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  Future<void> update({
    required String id,
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    final now = DateTime.now();

    return transaction(() async {
      if (labelIds != null) {
        db.execute("DELETE FROM saving_labels WHERE saving_id = ?", [id]);
        _createLabels(id: id, labelIds: labelIds);
      }

      _updateSaving({
        "id": id,
        "note": note,
        "goal": goal,
        "balance": 0,
        "account_id": accountId,
        "updated_at": now.toIso8601String(),
        "deleted_at": null,
      });
    });
  }

  Future<void> refresh(String id) async {
    return transaction<void>(() async {
      final ResultSet rows = db.select(
        "SELECT SUM(entries.amount) AS entries_amount FROM saving_entries JOIN entries ON entries.id = saving_entries.entry_id WHERE saving_entries.saving_id = ?",
        [id],
      );

      final entriesAmount = (rows.first["entries_amount"] ?? 0);

      db.execute("UPDATE savings SET balance = ? WHERE id = ?", [
        entriesAmount * -1,
        id,
      ]);
    });
  }

  Future<void> remove(String id) async {
    return transaction<void>(() async {
      db.execute("DELETE FROM saving_entries WHERE saving_id = ?", [id]);
      db.execute("DELETE FROM saving_labels WHERE saving_id = ?", [id]);
      db.execute("DELETE FROM savings WHERE id = ?", [id]);
    });
  }

  Future<void> _createLabels({
    required String id,
    List<String>? labelIds,
  }) async {
    final savingLabels = await _makeLabels(id: id, labelIds: labelIds);
    await _createSavingLabels(savingLabels);
  }

  Future<List<Map>> _makeLabels({
    required String id,
    List<String>? labelIds,
  }) async {
    if (labelIds == null) return [];
    return labelIds
        .map((labelId) => {"saving_id": id, "label_id": labelId})
        .toList();
  }

  Future<List<Saving>> _populate(ResultSet savingRows) async {
    final savingIds = savingRows.map((row) => row["id"] as String).toList();
    final accountIds = savingRows
        .map((row) => row["account_id"] as String)
        .toList();
    final accountRows = await getAccountByIds(accountIds);
    final labelRows = await _getSavingLabels(savingIds);

    return savingRows.map((savingRow) {
      final saving = Saving.fromRow(savingRow);

      saving.setAccount(
        Account.fromRow(
          accountRows.firstWhere(
            (accountRow) => accountRow["id"] == savingRow["account_id"],
          ),
        ),
      );

      saving.setLabels(
        labelRows
            .where((labelRow) => labelRow["saving_id"] == savingRow["id"])
            .map((labelRow) => Label.fromRow(labelRow))
            .toList(),
      );

      return saving;
    }).toList();
  }

  Map? _where(Map? spec) {
    if (spec == null) return null;

    final Map<String, dynamic> where = {
      "args": <dynamic>[],
      "query": <String>[],
      "sql": null,
    };

    where["sql"] = where["query"].join(" AND ");
    return where;
  }

  Future<ResultSet> _getSavingByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM savings WHERE id IN (${ids.map((_) => '?').join(", ")})",
      ids,
    );
  }

  Future<Map?> _getSavingById(String id) async {
    final rows = await _getSavingByIds([id]);
    return rows.firstOrNull;
  }

  Future<void> _updateSaving(Map saving) async {
    db.execute(
      "UPDATE savings SET note = ?, goal = ?, balance = ?, account_id = ?, updated_at = ? WHERE id = ?",
      [
        saving["note"],
        saving["goal"],
        saving["balance"],
        saving["account_id"],
        saving["updated_at"],
        saving["id"],
      ],
    );
  }

  Future<void> _createSaving(Map saving) async {
    db.execute(
      "INSERT INTO savings (id, note, goal, balance, account_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [
        saving["id"],
        saving["note"],
        saving["goal"],
        saving["balance"],
        saving["account_id"],
        saving["created_at"],
        saving["updated_at"],
      ],
    );
  }

  Future<void> _createSavingLabels(List<Map> savingLabels) async {
    final sql =
        "INSERT INTO saving_labels (saving_id, label_id) VALUES ${savingLabels.map((_) => '(?, ?)').join(', ')}";
    final args = savingLabels
        .map(
          (savingLabel) => [savingLabel["saving_id"], savingLabel["label_id"]],
        )
        .expand((args) => args)
        .toList();

    db.execute(sql, args);
  }

  Future<ResultSet> _getSavingLabels(List<String> ids) async {
    if (ids.isEmpty) return ResultSet([], [], []);
    final idsPlaceholder = ids.map((_) => "?").join(", ");
    final labelsQuery =
        """
      SELECT labels.*, saving_labels.saving_id FROM labels
      INNER JOIN saving_labels ON saving_labels.label_id = labels.id
      WHERE saving_labels.saving_id IN ($idsPlaceholder)
    """;
    return db.select(labelsQuery, ids);
  }

  Future<Map> _createEntry({
    required Saving saving,
    required TransactionType type,
    required double amount,
    required DateTime issuedAt,
    required DateTime now,
  }) async {
    final entry = await _makeEntry(
      saving: saving,
      type: type,
      amount: amount,
      issuedAt: issuedAt,
      now: now,
    );

    insertEntry(entry);

    return entry;
  }

  Future<Map> _makeEntry({
    required Saving saving,
    required TransactionType type,
    required double amount,
    required DateTime issuedAt,
    required DateTime now,
  }) async {
    final category = await getCategoryByName("Saving");

    return {
      "id": Repository.getId(),
      "note": type == TransactionType.deposit
          ? "Deposit to ${saving.note}"
          : "Withdraw from ${saving.note}",
      "amount": type == TransactionType.deposit ? amount * -1 : amount,
      "timestamp": issuedAt.toIso8601String(),
      "status": EntryStatus.done.label,
      "readonly": true,
      "category_id": category!["id"],
      "account_id": saving.accountId,
      "created_at": now.toIso8601String(),
      "updated_at": now.toIso8601String(),
    };
  }

  Future<void> _createEntryLabels({
    required String entryId,
    required DateTime now,
    List<String>? readonlyLabelIds,
    List<String>? writeableLabelIds,
  }) async {
    if (readonlyLabelIds == null && writeableLabelIds == null) return;

    db.execute("DELETE FROM entry_labels WHERE entry_labels.entry_id = ?", [
      entryId,
    ]);

    if (readonlyLabelIds != null && readonlyLabelIds.isNotEmpty) {
      db.execute(
        "INSERT INTO entry_labels (entry_id, label_id, readonly, created_at, updated_at) VALUES ${readonlyLabelIds.map((_) => '(?, ?, ?, ?, ?)').join(", ")}",
        readonlyLabelIds
            .map(
              (labelId) => [
                entryId,
                labelId,
                true,
                now.toIso8601String(),
                now.toIso8601String(),
              ],
            )
            .expand((i) => i)
            .toList(),
      );
    }

    if (writeableLabelIds != null && writeableLabelIds.isNotEmpty) {
      db.execute(
        "INSERT INTO entry_labels (entry_id, label_id, readonly, created_at, updated_at) VALUES ${writeableLabelIds.map((_) => '(?, ?, ?, ?, ?)').join(", ")}",
        writeableLabelIds
            .map(
              (labelId) => [
                entryId,
                labelId,
                false,
                now.toIso8601String(),
                now.toIso8601String(),
              ],
            )
            .expand((i) => i)
            .toList(),
      );
    }
  }
}
