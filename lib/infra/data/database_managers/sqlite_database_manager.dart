import 'dart:io';

import 'package:bandha/core/data/database_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class SqliteDatabaseManager implements DatabaseManager<Database> {
  Database? _db;

  final migrations = [
    "0001_init.sql",
    "0002_create_categories.sql",
    "0003_create_assets.sql",
    "0004_create_labels.sql",
    "0005_create_parties.sql",
    "0006_create_journals.sql",
    "0007_create_entries.sql",
    "0008_create_transfers.sql",
    "0009_create_obligations.sql",
    "0010_create_funds.sql",
    "0011_create_schedules.sql",
    "0012_insert_categories.sql",
    "0013_insert_labels.sql",
  ];

  Future<void> reset() async {
    if (_db == null) {
      return;
    }

    final db = _db!;

    db.execute("PRAGMA writable_schema = 1;");
    db.execute("PRAGMA foreign_keys = OFF;");
    final tables = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );

    for (var table in tables) {
      final tableName = table["name"] as String;
      try {
        db.execute("DROP TABLE IF EXISTS $tableName;");
      } catch (error, stackTrace) {
        if (kDebugMode) {
          print(error);
          print(stackTrace);
        }
      }
    }

    db.execute("PRAGMA foreign_keys = ON;");
    db.execute("PRAGMA writable_schema = 0;");
    db.execute("VACUUM;");
    db.execute('PRAGMA user_version = 0;');

    await reconnect();
  }

  Future<void> restore(String sourcePath) async {
    if (_db == null) {
      return;
    }

    _db!.close();

    final dbPath = await getPath();
    final dbFile = File(dbPath);
    if (await dbFile.exists()) await dbFile.delete();

    final walPath = "$dbPath-wal";
    final walFile = File(walPath);
    if (await walFile.exists()) await walFile.delete();

    final shmPath = "$dbPath-shm";
    final shmFile = File(shmPath);
    if (await shmFile.exists()) await shmFile.delete();

    final sourceFile = File(sourcePath);
    await sourceFile.copy(dbPath);

    await reconnect();
  }

  Future<String> backup(String snapshot) async {
    final db = await getInstance();
    final docDir = await getTemporaryDirectory();
    final dbDir = Directory(join(docDir.path, 'databases'));
    if (!dbDir.existsSync()) dbDir.createSync(recursive: true);
    final dbPath = join(dbDir.path, snapshot);
    final dbFile = File(dbPath);
    if (dbFile.existsSync()) return dbFile.path;
    db.execute("VACUUM INTO '$dbPath';");
    return dbPath;
  }

  @override
  Future<void> connect() async {
    final dbPath = await getPath();
    _db = sqlite3.open(dbPath);

    await _bind();
    await _migrate();
  }

  @override
  Future<void> disconnect() async {
    if (_db != null) {
      _db!.close();
    }

    _db = null;
  }

  @override
  Future<Database> getInstance() async {
    if (_db == null) {
      await connect();
      return _db!;
    }

    return _db!;
  }

  @override
  Future<void> reconnect() async {
    await disconnect();
    await connect();
  }

  Future<void> _bind() async {
    if (_db == null) {
      return;
    }

    final db = _db!;

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
        return Uuid().v7();
      },
    );
  }

  int? _getMigrationVersion() {
    if (_db == null) {
      return null;
    }

    final db = _db!;
    final rows = db.select('PRAGMA user_version;');
    if (rows.isEmpty) return null;
    return rows.first["user_version"];
  }

  Future<void> _migrate() async {
    if (_db == null) {
      return;
    }

    final db = _db!;

    final currentVersion = _getMigrationVersion() ?? 0;

    for (final migration in migrations) {
      final version = int.tryParse(migration.split("_").first);
      if (version == null) {
        continue;
      }

      if (currentVersion >= version) {
        continue;
      }

      final migrationPath = "assets/sql/$migration";
      final sql = await rootBundle.loadString(migrationPath);

      try {
        final statements = sql.split(";");
        for (var s in statements) {
          final statement = s.trim();
          db.execute(statement);
        }

        db.execute("PRAGMA user_version = '$migration';");
        if (kDebugMode) {
          print("SQLITE_DATABASE_MANAGER: $migration MIGRATED");
        }
      } catch (error, stackTrace) {
        if (kDebugMode) {
          print("SQLITE_DATABASE_MANAGER: $error");
          print("SQLITE_DATABASE_MANAGER: $stackTrace");
        }

        break;
      }
    }
  }

  Future<String> getDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dbDir = Directory(join(appDir.parent.path, 'databases'));
    if (!dbDir.existsSync()) dbDir.createSync(recursive: true);
    return dbDir.path;
  }

  Future<String> getPath() async {
    return join(await getDir(), "bandha.db");
  }
}
