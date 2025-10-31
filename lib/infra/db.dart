import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class DB {
  static final DB _instance = DB._internal();
  static Database? _db;
  factory DB() => _instance;

  DB._internal();

  static beginTransaction() {
    _db!.execute("BEGIN TRANSACTION");
  }

  static commit() {
    _db!.execute("COMMIT");
  }

  static rollback() {
    _db!.execute("ROLLBACK");
  }

  static Future<String> getDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dbDir = Directory(join(appDir.parent.path, 'databases'));
    if (!dbDir.existsSync()) dbDir.createSync(recursive: true);
    return dbDir.path;
  }

  static Future<String> getPath() async {
    return join(await DB.getDir(), "bandaio.db");
  }

  static Future<void> reset() async {
    final db = _db!;

    db.execute("PRAGMA writable_schema = 1");
    db.execute("DELETE FROM sqlite_master WHERE type='table'");
    db.execute("PRAGMA writable_schema = 0");
    db.execute("VACUUM");
    db.execute('PRAGMA user_version = 0;');

    setup(db);
  }

  Future<Database> get connection async {
    if (_db != null) return _db!;
    _db = sqlite3.open(await DB.getPath());
    return setup(_db!);
  }

  static getMigrationVersion(Database db) {
    final rows = db.select('PRAGMA user_version;');
    if (rows.isEmpty) return 0;
    return rows.first["user_version"] ?? 0;
  }

  static setup(Database db) {
    var migrationVersion = getMigrationVersion(db);

    db.createFunction(
      functionName: 'regexp',
      function: (args) {
        final pattern = args[0] as String;
        final value = args[1] as String?;
        return value != null && RegExp(pattern).hasMatch(value) ? 1 : 0;
      },
    );

    db.createFunction(
      functionName: 'uuid',
      function: (args) {
        return Uuid().v4();
      },
    );

    if (migrationVersion < 1) {
      db.execute('PRAGMA foreign_keys = ON;');

      db.execute(
        "CREATE TABLE IF NOT EXISTS accounts (id TEXT PRIMARY KEY, name TEXT NOT NULL, balance REAL NOT NULL, kind TEXT NOT NULL, holder_name TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS categories (id TEXT PRIMARY KEY, name TEXT NOT NULL UNIQUE, readonly BOOLEAN DEFAULT FALSE, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS entries (id TEXT PRIMARY KEY, note TEXT NOT NULL, amount REAL NOT NULL, issued_at TEXT NOT NULL, status TEXT NOT NULL, readonly BOOLEAN DEFAULT FALSE, category_id TEXT NOT NULL REFERENCES categories (id) ON DELETE CASCADE, account_id TEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS transfers (id TEXT PRIMARY KEY, note TEXT NOT NULL, amount REAL NOT NULL, issued_at TEXT NOT NULL, credit_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE, credit_account_id TEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE, debit_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE, debit_account_id TEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS labels (id TEXT PRIMARY KEY, name TEXT UNIQUE NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS entry_labels (entry_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE, label_id TEXT NOT NULL REFERENCES labels (id) ON DELETE CASCADE, PRIMARY KEY (entry_id, label_id))",
      );

      db.execute(
        "INSERT INTO categories (id, name, readonly, created_at, updated_at, deleted_at) VALUES (uuid(), 'Transfer', 1, strftime('%Y-%m-%dT%H:%M:%S','now'), strftime('%Y-%m-%dT%H:%M:%S','now'), NULL);",
      );

      migrationVersion = 1;
      db.execute('PRAGMA user_version = 1;');
    }

    if (migrationVersion < 2) {
      db.execute("ALTER TABLE transfers ADD COLUMN fee REAL;");
      migrationVersion = 2;
      db.execute('PRAGMA user_version = 2;');
    }

    if (migrationVersion < 3) {
      db.execute(
        "CREATE TABLE IF NOT EXISTS parties (id TEXT PRIMARY KEY, name TEXT UNIQUE NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS loans (id TEXT PRIMARY KEY, amount REAL NOT NULL, fee REAL, kind TEXT NOT NULL, status TEXT NOT NULL, issued_at TEXT NOT NULL, debit_account_id TEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE, credit_account_id TEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE, party_id TEXT NOT NULL REFERENCES parties (id) ON DELETE CASCADE, debit_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE, credit_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, settled_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        """INSERT INTO categories (id, name, readonly, created_at, updated_at, deleted_at) VALUES
  (uuid(), 'Debt', 1, strftime('%Y-%m-%dT%H:%M:%S','now'), strftime('%Y-%m-%dT%H:%M:%S','now'), NULL),
  (uuid(), 'Receivable', 1, strftime('%Y-%m-%dT%H:%M:%S','now'), strftime('%Y-%m-%dT%H:%M:%S','now'), NULL);""",
      );

      migrationVersion = 3;
      db.execute('PRAGMA user_version = 3;');
    }

    if (migrationVersion < 4) {
      db.execute(
        "CREATE TABLE IF NOT EXISTS savings (id TEXT PRIMARY KEY, note TEXT NOT NULL, goal REAL NOT NULL, balance REAL NOT NULL, status TEXT NOT NULL, account_id TEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, released_at TEXT, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS savings_entries (entry_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE, savings_id TEXT NOT NULL REFERENCES savings (id) ON DELETE CASCADE, PRIMARY KEY (entry_id, savings_id))",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS savings_labels (label_id TEXT NOT NULL REFERENCES labels (id) ON DELETE CASCADE, savings_id TEXT NOT NULL REFERENCES savings (id) ON DELETE CASCADE, PRIMARY KEY (label_id, savings_id))",
      );

      db.execute(
        "INSERT INTO categories (id, name, readonly, created_at, updated_at, deleted_at) VALUES (uuid(), 'Saving', 1, strftime('%Y-%m-%dT%H:%M:%S','now'), strftime('%Y-%m-%dT%H:%M:%S','now'), NULL);",
      );

      migrationVersion = 4;
      db.execute('PRAGMA user_version = 4;');
    }

    if (migrationVersion < 5) {
      db.execute(
        "CREATE TABLE IF NOT EXISTS bills (id TEXT PRIMARY KEY, note TEXT NOT NULL, amount REAL NOT NULL, cycle TEXT NOT NULL, status TEXT NOT NULL, entry_id TEXT NOT NULL REFERENCES entries (id), category_id TEXT NOT NULL REFERENCES categories (id) ON DELETE CASCADE, account_id TEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE, billed_at TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS bill_entries (entry_id TEXT NOT NULL REFERENCES entries (id) ON DELETE CASCADE, bill_id TEXT NOT NULL REFERENCES bills (id) ON DELETE CASCADE, PRIMARY KEY (entry_id, bill_id))",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS bill_labels (label_id TEXT NOT NULL REFERENCES labels (id) ON DELETE CASCADE, bill_id TEXT NOT NULL REFERENCES bills (id) ON DELETE CASCADE, PRIMARY KEY (label_id, bill_id))",
      );

      migrationVersion = 5;
      db.execute('PRAGMA user_version = 5;');
    }

    if (migrationVersion < 6) {
      db.execute(
        'CREATE TABLE IF NOT EXISTS budgets (id TEXT PRIMARY KEY, note TEXT NOT NULL, usage REAL NOT NULL, "limit" REAL NOT NULL, cycle TEXT NOT NULL, category_id TEXT NOT NULL REFERENCES categories (id) ON DELETE CASCADE, expired_at TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)',
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS budget_labels (label_id TEXT NOT NULL REFERENCES labels (id) ON DELETE CASCADE, budget_id TEXT NOT NULL REFERENCES budgets (id) ON DELETE CASCADE, PRIMARY KEY (label_id, budget_id))",
      );

      migrationVersion = 6;
      db.execute('PRAGMA user_version = 6;');
    }

    return db;
  }
}
