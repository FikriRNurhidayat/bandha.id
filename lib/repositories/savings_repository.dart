import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/label.dart';
import 'package:banda/entity/savings.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/specification.dart';
import 'package:sqlite3/sqlite3.dart';

class SavingsRepository extends Repository {
  final WithArgs withArgs;

  SavingsRepository(super.db, {WithArgs? withArgs}) : withArgs = withArgs ?? {};

  static Future<SavingsRepository> build() async {
    final db = await Repository.connect();
    return SavingsRepository(db);
  }

  SavingsRepository withAccount() {
    withArgs.add("account");
    return SavingsRepository(db, withArgs: withArgs);
  }

  SavingsRepository withLabels() {
    withArgs.add("labels");
    return SavingsRepository(db, withArgs: withArgs);
  }

  Future<void> save(Savings savings) async {
    db.execute(
      "INSERT INTO savings (id, note, goal, balance, status, account_id, created_at, updated_at, released_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET note = excluded.note, goal = excluded.goal, balance = excluded.balance, account_id = excluded.account_id, updated_at = excluded.updated_at, status = excluded.status, released_at = excluded.released_at",
      [
        savings.id,
        savings.note,
        savings.goal,
        savings.balance,
        savings.status.label,
        savings.accountId,
        savings.createdAt.toIso8601String(),
        savings.updatedAt.toIso8601String(),
        savings.releasedAt?.toIso8601String(),
      ],
    );
  }

  Future<List<Savings>> search(Specification? spec) async {
    final rows = db.select("SELECT savings.* FROM savings");
    return entities(rows);
  }

  Future<Savings?> get(String id) async {
    final rows = db.select("SELECT * FROM savings WHERE id = ?", [id]);
    return entities(rows).then((savings) => savings.firstOrNull);
  }

  Future<void> sync(String id) async {
    return Repository.work<void>(() async {
      final ResultSet rows = db.select(
        "SELECT SUM(entries.amount) AS balance FROM savings_entries JOIN entries ON entries.id = savings_entries.entry_id WHERE savings_entries.savings_id = ? AND entries.status = ?",
        [id, EntryStatus.done.label],
      );

      final balance = (rows.first["balance"] ?? 0);

      db.execute("UPDATE savings SET balance = ? WHERE id = ?", [
        balance * -1,
        id,
      ]);
    });
  }

  Future<void> addEntry(Savings savings, Entry entry) async {
    db.execute(
      "INSERT INTO savings_entries (savings_id, entry_id) VALUES (?, ?)",
      [savings.id, entry.id],
    );
  }

  Future<void> removeEntry(Savings savings, Entry entry) async {
    db.execute(
      "DELETE FROM savings_entries WHERE savings_id = ? AND entry_id = ?",
      [savings.id, entry.id],
    );

    db.execute("DELETE FROM entries WHERE id = ?", [entry.id]);
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM savings WHERE id = ?", [id]);
  }

  Future<void> flushEntries(Savings savings) async {
    db.execute(
      "DELETE FROM entries WHERE id IN (SELECT savings_entries.entry_id FROM savings_entries WHERE savings_entries.savings_id = ?)",
      [savings.id],
    );
  }

  setLabels(String savingsId, List<String> labelIds) {
    return setEntityLabels(
      entityId: savingsId,
      labelIds: labelIds,
      junctionTable: "savings_labels",
      junctionKey: "savings_id",
    );
  }

  Future<void> removeLabels(Savings savings) async {
    return resetEntityLabels(
      entityId: savings.id,
      junctionTable: "savings_labels",
      junctionKey: "savings_id",
    );
  }

  populateSavingLabels(List<Map> rows) {
    return super.populateLabels(rows, "savings_labels", "savings_id");
  }

  Future<List<Savings>> entities(List<Map> rows) async {
    if (withArgs.contains("account")) {
      rows = await populateAccount(rows);
    }

    if (withArgs.contains("labels")) {
      rows = await populateSavingLabels(rows);
    }

    return rows
        .map(
          (row) => Savings.fromRow(row)
              .withLabels(Label.fromRows(row["labels"]))
              .withAccount(Account.fromRow(row["account"])),
        )
        .toList();
  }
}
