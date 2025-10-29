import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/specification.dart';
import 'package:sqlite3/sqlite3.dart';

class SavingRepository extends Repository {
  final WithArgs withArgs;

  SavingRepository(super.db, {WithArgs? withArgs}) : withArgs = withArgs ?? {};

  static Future<SavingRepository> build() async {
    final db = await Repository.connect();
    return SavingRepository(db);
  }

  SavingRepository withAccount() {
    withArgs.add("account");
    return SavingRepository(db, withArgs: withArgs);
  }

  SavingRepository withLabels() {
    withArgs.add("labels");
    return SavingRepository(db, withArgs: withArgs);
  }

  Future<void> save(Saving saving) async {
    db.execute(
      "INSERT INTO savings (id, note, goal, balance, status, account_id, created_at, updated_at, released_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET note = excluded.note, goal = excluded.goal, balance = excluded.balance, account_id = excluded.account_id, updated_at = excluded.updated_at, status = excluded.status, released_at = excluded.released_at",
      [
        saving.id,
        saving.note,
        saving.goal,
        saving.balance,
        saving.status.label,
        saving.accountId,
        saving.createdAt.toIso8601String(),
        saving.updatedAt.toIso8601String(),
        saving.releasedAt?.toIso8601String(),
      ],
    );
  }

  Future<List<Saving>> search(Specification? spec) async {
    final rows = db.select("SELECT savings.* FROM savings");
    return entities(rows);
  }

  Future<Saving?> get(String id) async {
    final rows = db.select("SELECT * FROM savings WHERE id = ?", [id]);
    return entities(rows).then((savings) => savings.firstOrNull);
  }

  Future<void> sync(String id) async {
    return Repository.work<void>(() async {
      final ResultSet rows = db.select(
        "SELECT SUM(entries.amount) AS balance FROM saving_entries JOIN entries ON entries.id = saving_entries.entry_id WHERE saving_entries.saving_id = ? AND entries.status = ?",
        [id, EntryStatus.done.label],
      );

      final balance = (rows.first["balance"] ?? 0);

      db.execute("UPDATE savings SET balance = ? WHERE id = ?", [
        balance * -1,
        id,
      ]);
    });
  }

  Future<void> addEntry(Saving saving, Entry entry) async {
    db.execute(
      "INSERT INTO saving_entries (saving_id, entry_id) VALUES (?, ?)",
      [saving.id, entry.id],
    );
  }

  Future<void> removeEntry(Saving saving, Entry entry) async {
    db.execute(
      "DELETE FROM saving_entries WHERE saving_id = ? AND entry_id = ?",
      [saving.id, entry.id],
    );

    db.execute("DELETE FROM entries WHERE id = ?", [entry.id]);
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM savings WHERE id = ?", [id]);
  }

  Future<void> flushEntries(Saving saving) async {
    db.execute(
      "DELETE FROM entries WHERE id IN (SELECT saving_entries.entry_id FROM saving_entries WHERE saving_entries.saving_id = ?)",
      [saving.id],
    );
  }

  setLabels(String savingId, List<String> labelIds) {
    return setEntityLabels(
      entityId: savingId,
      labelIds: labelIds,
      junctionTable: "saving_labels",
      junctionKey: "saving_id",
    );
  }

  Future<void> removeLabels(Saving saving) async {
    return resetEntityLabels(
      entityId: saving.id,
      junctionTable: "saving_labels",
      junctionKey: "saving_id",
    );
  }

  populateSavingLabels(List<Map> rows) {
    return super.populateLabels(rows, "saving_labels", "saving_id");
  }

  Future<List<Saving>> entities(List<Map> rows) async {
    if (withArgs.contains("account")) {
      rows = await populateAccount(rows);
    }

    if (withArgs.contains("labels")) {
      rows = await populateSavingLabels(rows);
    }

    return rows
        .map(
          (row) => Saving.fromRow(row)
              .withLabels(Label.fromRows(row["labels"]))
              .withAccount(Account.fromRow(row["account"])),
        )
        .toList();
  }
}
