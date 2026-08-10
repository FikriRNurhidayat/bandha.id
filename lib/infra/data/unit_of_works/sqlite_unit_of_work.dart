import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteUnitOfWork implements UnitOfWork {
  final DatabaseManager<Database> dbManager;
  final DomainEventPublisher domainEventPublisher;

  static SqliteUnitOfWork create(DependencyContainer c) {
    final dbManager = c.get<DatabaseManager<Database>>();
    return SqliteUnitOfWork(
      dbManager,
      domainEventPublisher: c.get<DomainEventPublisher>(),
    );
  }

  SqliteUnitOfWork(this.dbManager, {required this.domainEventPublisher});

  @override
  Future<R> execute<R>(Future<R> Function() block) async {
    try {
      final db = await dbManager.getInstance();

      db.execute("BEGIN;");

      try {
        final retval = await block();
        await domainEventPublisher.dispatch();
        db.execute("COMMIT;");
        return retval;
      } catch (error) {
        db.execute("ROLLBACK;");

        rethrow;
      }
    } catch (error) {
      rethrow;
    }
  }
}
