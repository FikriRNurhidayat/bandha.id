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

  Future<void> deleteSavingEntry(Saving saving, String id) {
    final now = DateTime.now();

    return atomic(() async {
      final savingRow = Map.from(await getSavingById(saving.id));
      final entry = await getEntryById(id);
      final delta = entry["amount"];
      savingRow["updated_at"] = now.toIso8601String();
      savingRow["balance"] += delta;

      db.execute("DELETE FROM entries WHERE id = ?", [id]);
      db.execute("DELETE FROM saving_entries WHERE entry_id = ?", [id]);
      db.execute("DELETE FROM entry_labels WHERE entry_id = ?", [id]);

      await updateSaving(savingRow);
    });
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
    return atomic(() async {
      final savingRow = Map.from(await getSavingById(saving.id));
      final initEntry = await getEntryById(id);

      final nextEntry = {
        ...Map.from(initEntry),
        "note": type == TransactionType.deposit
            ? "Deposit to ${saving.note}"
            : "Withdraw from ${saving.note}",
        "amount": type == TransactionType.deposit ? amount * -1 : amount,
        "timestamp": issuedAt.toIso8601String(),
        "updated_at": now.toIso8601String(),
      };

      await setEntityLabels(
        entityId: nextEntry["id"],
        labelIds: labelIds,
        junctionTable: "entry_labels",
        junctionKey: "entry_id",
      );

      final delta = nextEntry["amount"] - initEntry["amount"];
      savingRow["updated_at"] = now.toIso8601String();
      savingRow["balance"] += (delta * -1);

      await updateSaving(savingRow);
      await updateEntry(nextEntry, nextEntry["amount"] - initEntry["amount"]);
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

    return atomic(() async {
      final savingRow = Map.from(await getSavingById(saving.id));
      savingRow["balance"] += type == TransactionType.deposit
          ? amount
          : amount * -1;

      final entryRow = await _makeEntry(
        saving: saving,
        type: type,
        amount: amount,
        issuedAt: issuedAt,
        now: now,
      );

      await insertEntry(entryRow);
      await setEntityLabels(
        entityId: entryRow["id"],
        labelIds: labelIds,
        junctionTable: "entry_labels",
        junctionKey: "entry_id",
      );
      await updateSaving(savingRow);

      db.execute(
        "INSERT INTO saving_entries (saving_id, entry_id) VALUES (?, ?)",
        [saving.id, entryRow["id"]],
      );
    });
  }

  Future<List<Saving>> search(Map? spec) async {
    var baseQuery = "SELECT savings.* FROM savings";
    var sqlArgs = <dynamic>[];
    final where = _where(spec);
    if (where != null && where["sql"].isNotEmpty) {
      baseQuery = "$baseQuery WHERE ${where["sql"]}";
      sqlArgs = where["args"];
    }

    final savingRows = db.select(
      "$baseQuery ORDER BY savings.created_at DESC",
      sqlArgs,
    );

    return populate(savingRows);
  }

  Future<Saving?> get(String id) async {
    final savingRows = db.select("SELECT * FROM savings WHERE id = ?", [id]);
    return populate(savingRows).then((savings) => savings.firstOrNull);
  }

  Future<Saving> create({
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    final id = Repository.getId();
    final now = DateTime.now();
    return atomic<Saving>(() async {
      final savingRow = {
        "id": id,
        "note": note,
        "goal": goal,
        "balance": 0,
        "account_id": accountId,
        "created_at": now.toIso8601String(),
        "updated_at": now.toIso8601String(),
        "deleted_at": null,
      };

      await createSaving(savingRow);

      await setEntityLabels(
        entityId: id,
        labelIds: labelIds,
        junctionTable: "saving_labels",
        junctionKey: "saving_id",
      );

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

    return atomic(() async {
      final savingRow = await getSavingById(id);

      await updateSaving({
        "id": id,
        "note": note,
        "goal": goal,
        "balance": savingRow["balance"],
        "account_id": accountId,
        "updated_at": now.toIso8601String(),
        "deleted_at": null,
      });

      await setEntityLabels(
        entityId: id,
        labelIds: labelIds,
        junctionTable: "saving_labels",
        junctionKey: "saving_id",
      );
    });
  }

  Future<void> refresh(String id) async {
    return atomic<void>(() async {
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
    return atomic<void>(() async {
      db.execute("DELETE FROM saving_entries WHERE saving_id = ?", [id]);
      db.execute("DELETE FROM saving_labels WHERE saving_id = ?", [id]);
      db.execute("DELETE FROM savings WHERE id = ?", [id]);
    });
  }

  Future<List<Saving>> populate(ResultSet rows) async {
    return populateLabels(rows, "saving_labels", "saving_id")
        .then((rows) => populateAccount(rows))
        .then(
          (rows) => rows
              .map(
                (row) => Saving.fromRow(row)
                    .setLabels(Label.fromRows(row["labels"]))
                    .setAccount(Account.fromRow(row["account"])),
              )
              .toList(),
        );
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

  Future<Map> getSavingById(String id) async {
    final rows = await _getSavingByIds([id]);
    return rows.first;
  }

  Future<void> updateSaving(Map saving) async {
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

  Future<void> createSaving(Map saving) async {
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
}
