import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/database_managers/sqlite_database_manager.dart';

class ResetLedger extends UseCase<void, void> {
  final SqliteDatabaseManager databaseManager;

  factory ResetLedger.fromContainer(DependencyContainer c) {
    return ResetLedger(databaseManager: c.get<SqliteDatabaseManager>());
  }

  ResetLedger({required this.databaseManager});

  @override
  Future<void> execute(void params) async {
    await databaseManager.reset();
  }
}
