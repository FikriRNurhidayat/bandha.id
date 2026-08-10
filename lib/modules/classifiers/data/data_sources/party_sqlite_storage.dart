import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/data/data_sources/classifier_sqlite_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/party_local_storage.dart';
import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:sqlite3/sqlite3.dart';

class PartySqliteStorage extends ClassifierSqliteStorage<Party>
    implements PartyLocalStorage {
  @override
  final DatabaseManager<Database> dbManager;

  PartySqliteStorage(this.dbManager);

  factory PartySqliteStorage.build(DependencyContainer c) {
    return PartySqliteStorage(c.get<DatabaseManager<Database>>());
  }

  @override
  Iterable<String> get columns => ["id", "name", "created_at", "updated_at"];

  @override
  Party? Function(Row? r) get entityBuilder =>
      (r) => Party.tryRow(r);

  @override
  String get table => "parties";

  @override
  Function(Party e) get valueBuilder =>
      (e) => [
        e.id,
        e.name,
        e.createdAt.toIso8601String(),
        e.updatedAt.toIso8601String(),
      ];
}
