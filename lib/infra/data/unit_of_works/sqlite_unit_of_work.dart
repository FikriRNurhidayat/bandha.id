import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:sqlite3/sqlite3.dart';

class SqliteUnitOfWork implements UnitOfWork {
  final Database db;
  final DomainEventPublisher domainEventPublisher;

  static SqliteUnitOfWork create(DependencyContainer c) {
    final db = c.get<Database>();
    return SqliteUnitOfWork(
      db,
      domainEventPublisher: c.get<DomainEventPublisher>(),
    );
  }

  SqliteUnitOfWork(this.db, {required this.domainEventPublisher});

  @override
  Future<R> execute<R>(Future<R> Function() block) async {
    try {
      db.execute("BEGIN");

      try {
        final retval = await block();
        await domainEventPublisher.dispatch();
        db.execute("COMMIT");
        return retval;
      } catch (error) {
        db.execute("ABORT");

        rethrow;
      }
    } catch (error) {
      rethrow;
    }
  }
}
