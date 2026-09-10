import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/database_managers/sqlite_database_manager.dart';
import 'package:bandha/infra/platform/file_picker.dart';
import 'package:bandha/modules/tools/domain/exceptions/invalid_database_exception.dart';
import 'package:flutter/foundation.dart';

class BackupLedger {
  final SqliteDatabaseManager databaseManager;
  final FilePicker filePicker;

  factory BackupLedger.build(DependencyContainer c) {
    return BackupLedger(
      databaseManager: c.get<SqliteDatabaseManager>(),
      filePicker: c.get<FilePicker>(),
    );
  }

  BackupLedger({required this.databaseManager, required this.filePicker});

  Future<String> execute() async {
    final now = DateTime.now();
    final snapshot =
        "${now.year.toString().padLeft(4, '0')}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}-"
        "${now.hour.toString().padLeft(2, '0')}-"
        "${now.minute.toString().padLeft(2, '0')}.db";
    final dbPath = await databaseManager.backup(snapshot);

    final outputPath = await filePicker.saveFile(
      fileName: snapshot,
      filePath: dbPath,
      mimeType: "application/vnd.sqlite3",
    );

    if (outputPath == null) {
      throw InvalidDatabaseException();
    }

    return outputPath;
  }
}
