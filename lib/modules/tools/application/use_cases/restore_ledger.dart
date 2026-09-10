import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/database_managers/sqlite_database_manager.dart';
import 'package:bandha/infra/platform/file_picker.dart';
import 'package:bandha/modules/tools/domain/exceptions/invalid_database_exception.dart';

class RestoreLedger {
  RestoreLedger({required this.databaseManager, required this.filePicker});

  final SqliteDatabaseManager databaseManager;
  final FilePicker filePicker;

  factory RestoreLedger.build(DependencyContainer c) {
    return RestoreLedger(
      databaseManager: c.get<SqliteDatabaseManager>(),
      filePicker: c.get<FilePicker>(),
    );
  }

  Future<void> execute() async {
    final sourcePath = await filePicker.getFile(
      mimeTypes: [
        "application/vnd.sqlite3",
        "application/x-sqlite3",
        "application/octet-stream",
      ],
    );

    if (sourcePath == null) {
      throw InvalidDatabaseException();
    }

    await databaseManager.restore(sourcePath);
  }
}
