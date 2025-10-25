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

  Future<Map?> getTransferById(String id) async {
    final ResultSet rows = db.select("SELECT * FROM accounts WHERE id = ?", [
      id,
    ]);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<Map?> getAccountById(String id) async {
    final ResultSet rows = db.select("SELECT * FROM accounts WHERE id = ?", [
      id,
    ]);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<Map?> getPartyById(String id) async {
    final ResultSet rows = db.select("SELECT * FROM parties WHERE id = ?", [
      id,
    ]);

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
      final result = callback();
      commit();
      return result;
    } catch (error) {
      rollback();
      rethrow;
    }
  }
}
