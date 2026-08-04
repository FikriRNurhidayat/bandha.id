import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/database_managers/sqlite_database_manager.dart';

class BackupLedger {
  final SqliteDatabaseManager databaseManager;

  factory BackupLedger.fromContainer(DependencyContainer c) {
    return BackupLedger(
      databaseManager: c.get<SqliteDatabaseManager>(),
    );
  }

  BackupLedger({required this.databaseManager});

  Future<void> call({required String destinationPath}) async {
    await databaseManager.backup(destinationPath);
  }
}
