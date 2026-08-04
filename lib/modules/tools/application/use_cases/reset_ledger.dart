import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/database_managers/sqlite_database_manager.dart';

class ResetLedger {
  final SqliteDatabaseManager databaseManager;

  factory ResetLedger.fromContainer(DependencyContainer c) {
    return ResetLedger(databaseManager: c.get<SqliteDatabaseManager>());
  }

  ResetLedger({required this.databaseManager});

  Future<void> call() async {
    await databaseManager.reset();
  }
}
