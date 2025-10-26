import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class Store {
  static final Store _instance = Store._internal();
  static Database? _db;
  factory Store() => _instance;

  Store._internal();

  static Future<String> getDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dbDir = Directory(join(appDir.parent.path, 'databases'));
    if (!dbDir.existsSync()) dbDir.createSync(recursive: true);
    return dbDir.path;
  }

  static Future<String> getPath() async {
    return join(await Store.getDir(), "bandaio.db");
  }

  static Future<void> reset() async {
    final db = _db!;
    final tables = db.select(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );

    for (final row in tables) {
      db.execute('DROP TABLE IF EXISTS ${row['name']};');
    }

    db.execute('PRAGMA user_version = 0;');

    setup(db);
  }

  Future<Database> get connection async {
    if (_db != null) return _db!;
    _db = sqlite3.open(await Store.getPath());
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
        "CREATE TABLE IF NOT EXISTS accounts (id TEXT PRIMARY KEY, name TEXT NOT NULL, kind TEXT NOT NULL, holder_name TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS categories (id TEXT PRIMARY KEY, name TEXT NOT NULL UNIQUE, readonly BOOLEAN DEFAULT FALSE, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS entries (id TEXT PRIMARY KEY, note TEXT NOT NULL, amount REAL NOT NULL, timestamp TEXT NOT NULL, status TEXT NOT NULL, readonly BOOLEAN DEFAULT FALSE, category_id TEXT NOT NULL REFERENCES categories (id), account_id TEXT NOT NULL REFERENCES accounts (id), created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS transfers (id TEXT PRIMARY KEY, note TEXT NOT NULL, amount REAL NOT NULL, timestamp TEXT NOT NULL, from_entry_id TEXT NOT NULL REFERENCES entries (id), to_entry_id TEXT NOT NULL REFERENCES entries (id), created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS labels (id TEXT PRIMARY KEY, name TEXT UNIQUE NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS entry_labels (entry_id TEXT NOT NULL, label_id TEXT NOT NULL, readonly BOOLEAN, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, PRIMARY KEY (entry_id, label_id))",
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
        "CREATE TABLE IF NOT EXISTS loans (id TEXT PRIMARY KEY, amount REAL NOT NULL, fee REAL, kind TEXT NOT NULL, status TEXT NOT NULL, issued_at TEXT NOT NULL, account_id TEXT NOT NULL REFERENCES accounts (id), party_id TEXT NOT NULL REFERENCES parties (id), debit_id TEXT NOT NULL REFERENCES entries (id), credit_id TEXT NOT NULL REFERENCES entries (id), created_at TEXT NOT NULL, updated_at TEXT NOT NULL, settled_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        """INSERT INTO categories (id, name, readonly, created_at, updated_at, deleted_at) VALUES
  (uuid(), 'Debt', 1, strftime('%Y-%m-%dT%H:%M:%S','now'), strftime('%Y-%m-%dT%H:%M:%S','now'), NULL),
  (uuid(), 'Receivable', 1, strftime('%Y-%m-%dT%H:%M:%S','now'), strftime('%Y-%m-%dT%H:%M:%S','now'), NULL),
  (uuid(), 'Debt Payment', 1, strftime('%Y-%m-%dT%H:%M:%S','now'), strftime('%Y-%m-%dT%H:%M:%S','now'), NULL),
  (uuid(), 'Receivable Payment', 1, strftime('%Y-%m-%dT%H:%M:%S','now'), strftime('%Y-%m-%dT%H:%M:%S','now'), NULL);
  ;""",
      );

      migrationVersion = 3;
      db.execute('PRAGMA user_version = 3;');
    }

    if (migrationVersion < 4) {
      db.execute(
        "CREATE TABLE IF NOT EXISTS savings (id TEXT PRIMARY KEY, note TEXT NOT NULL, goal REAL NOT NULL, balance REAL NOT NULL, account_id TEXT NOT NULL REFERENCES accounts (id), created_at TEXT NOT NULL, updated_at TEXT NOT NULL, deleted_at TEXT)",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS saving_entries (entry_id TEXT NOT NULL, saving_id TEXT NOT NULL, PRIMARY KEY (entry_id, saving_id))",
      );

      db.execute(
        "CREATE TABLE IF NOT EXISTS saving_labels (label_id TEXT NOT NULL, saving_id TEXT NOT NULL, PRIMARY KEY (label_id, saving_id))",
      );

      db.execute(
        "INSERT INTO categories (id, name, readonly, created_at, updated_at, deleted_at) VALUES (uuid(), 'Saving', 1, strftime('%Y-%m-%dT%H:%M:%S','now'), strftime('%Y-%m-%dT%H:%M:%S','now'), NULL);",
      );

      migrationVersion = 4;
      db.execute('PRAGMA user_version = 4;');
    }

    return db;
  }
}
