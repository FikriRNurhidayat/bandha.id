import 'package:banda/entity/saving.dart';
import 'package:banda/repositories/repository.dart';
import 'package:sqlite3/sqlite3.dart';

class SavingRepository extends Repository {
  SavingRepository._(super.db);

  static Future<SavingRepository> build() async {
    final db = await Repository.connect();
    return SavingRepository._(db);
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

      final savingLabels = await _makeLabels(id: id, labelIds: labelIds);
      for (var savingLabel in savingLabels) {
        await _createSavingLabel(savingLabel);
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
    throw UnimplementedError();
  }

  Future<void> remove(String id) async {
    return transaction<void>(() async {
      db.execute("DELETE FROM saving_entries WHERE saving_id = ?", [id]);
      db.execute("DELETE FROM saving_labels WHERE saving_id = ?", [id]);
      db.execute("DELETE FROM savings WHERE id = ?", [id]);
    });
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
    return savingRows.map((savingRow) {
      final saving = Saving.fromRow(savingRow);
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

  Future<void> _createSavingLabel(Map savingLabel) async {
    db.execute(
      "INSERT INTO saving_labels (saving_id, label_id) VALUES (?, ?)",
      [savingLabel["saving_id"], savingLabel["label_id"]],
    );
  }
}
