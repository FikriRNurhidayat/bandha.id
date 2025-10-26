import 'package:banda/infra/store.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class Repository {
  final Database db;
  Repository(this.db);
  static Future<Database> connect() => Store().connection;

  static String getId() {
    return Uuid().v4();
  }

  static String getTime() {
    return DateTime.now().toIso8601String();
  }

  Future<Row?> getTransferById(String id) async {
    final ResultSet rows = db.select("SELECT * FROM accounts WHERE id = ?", [
      id,
    ]);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<ResultSet> getAccountByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM accounts WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  Future<Row?> getAccountById(String id) async {
    final rows = await getAccountByIds([id]);
    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<ResultSet> getEntryByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM entries WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  Future<Row?> getEntryById(String id) async {
    final rows = await getEntryByIds([id]);
    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<ResultSet> getPartyByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM parties WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  Future<Row?> getPartyById(String id) async {
    final rows = await getPartyByIds([id]);
    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<Map?> getCategoryByName(String name) async {
    final ResultSet rows = db.select(
      "SELECT * FROM categories WHERE name = ?",
      [name],
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<void> updateEntry(Map entry) async {
    db.execute(
      "UPDATE entries SET note = ?, amount = ?, status = ?, readonly = ?, timestamp = ?, category_id = ?, account_id = ?, updated_at = ? WHERE id = ?",
      [
        entry["note"],
        entry["amount"],
        entry["status"],
        entry["readonly"],
        entry["timestamp"],
        entry["category_id"],
        entry["account_id"],
        entry["updated_at"],
        entry["id"],
      ],
    );
  }

  Future<void> insertEntry(Map entry) async {
    db.execute(
      "INSERT INTO entries (id, note, amount, status, readonly, timestamp, category_id, account_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        entry["id"],
        entry["note"],
        entry["amount"],
        entry["status"],
        entry["readonly"],
        entry["timestamp"],
        entry["category_id"],
        entry["account_id"],
        entry["created_at"],
        entry["updated_at"],
      ],
    );
  }

  beginTransaction() {
    db.execute("BEGIN TRANSACTION");
  }

  commit() {
    db.execute("COMMIT");
  }

  rollback() {
    db.execute("ROLLBACK");
  }

  Future<T> transaction<T>(Future<T> Function() callback) async {
    try {
      beginTransaction();
      final result = await callback();
      commit();
      return result;
    } catch (error) {
      rollback();
      rethrow;
    }
  }
}
