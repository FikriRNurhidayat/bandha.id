import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/data_sources/sqlite_storage.dart';
import 'package:bandha/modules/journals/data/data_sources/journal_local_storage.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:sqlite3/sqlite3.dart';

class JournalSqliteStorage extends SqliteStorage<Journal>
    implements JournalLocalStorage {
  @override
  final DatabaseManager<Database> dbManager;

  JournalSqliteStorage(this.dbManager);

  factory JournalSqliteStorage.build(DependencyContainer c) {
    return JournalSqliteStorage(c.get<DatabaseManager<Database>>());
  }

  @override
  Future<void> balance(String id) {
    throw UnimplementedError();
  }

  @override
  Iterable<String> get columns => [
    "id",
    "name",
    "holder_name",
    "balance",
    "asset_id",
    "created_at",
    "updated_at",
  ];

  @override
  Journal? Function(Row? r) get entityBuilder =>
      (r) => Journal.tryRow(r);

  @override
  String get table => "journals";

  @override
  Function(Journal e) get valueBuilder =>
      (e) => [
        e.id,
        e.name,
        e.holderName,
        e.balance,
        e.assetId,
        e.createdAt.toIso8601String(),
        e.updatedAt.toIso8601String(),
      ];
}
