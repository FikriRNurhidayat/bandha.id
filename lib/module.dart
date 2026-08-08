import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/infra/data/database_managers/sqlite_database_manager.dart';
import 'package:bandha/infra/data/unit_of_works/sqlite_unit_of_work.dart';
import 'package:bandha/infra/events/in_memory_domain_event_publisher.dart';
import 'package:bandha/modules/assets/module.dart';
import 'package:bandha/modules/classifiers/module.dart';
import 'package:bandha/modules/entries/module.dart';
import 'package:bandha/modules/journals/module.dart';
import 'package:bandha/modules/tools/module.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

Future<DependencyContainer> bootstrap() async {
  final s = DateTime.now();
  final c = DependencyContainer();
  final databaseManager = SqliteDatabaseManager();
  final database = await databaseManager.getInstance();
  final domainEventPublisher = InMemoryDomainEventPublisher();

  c.registerSingleton<SqliteDatabaseManager>(databaseManager);
  c.registerSingleton<DatabaseManager<Database>>(databaseManager);
  c.registerSingleton<Database>(database);
  c.registerSingleton<DomainEventPublisher>(domainEventPublisher);

  final unitOfWork = SqliteUnitOfWork.create(c);
  c.registerSingleton<UnitOfWork>(unitOfWork);

  for (final module in <Module>[
    ClassifierModule(),
    AssetModule(),
    JournalModule(),
    EntryModule(),
    ToolModule(),
  ]) {
    await module.provide(c);
    await module.compose(c);
    await module.event(c, domainEventPublisher);
  }

  final e = DateTime.now();

  if (kDebugMode) {
    print("Bootstrap took: ${e.difference(s)}");
  }

  return c;
}
