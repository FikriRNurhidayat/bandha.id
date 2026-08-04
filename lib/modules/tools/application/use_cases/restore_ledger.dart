import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/database_managers/sqlite_database_manager.dart';

class RestoreLedger {
  final SqliteDatabaseManager databaseManager;

  factory RestoreLedger.fromContainer(DependencyContainer c) {
    return RestoreLedger(
      databaseManager: c.get<SqliteDatabaseManager>(),
    );
  }

  RestoreLedger({required this.databaseManager});

  Future<void> call({required String sourcePath}) async {
    await databaseManager.restore(sourcePath);
  }
}
