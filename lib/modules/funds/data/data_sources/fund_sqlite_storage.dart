import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/data_sources/sqlite_storage.dart';
import 'package:bandha/modules/funds/data/data_sources/fund_local_storage.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:sqlite3/sqlite3.dart';

class FundSqliteStorage extends SqliteStorage<Fund>
    implements FundLocalStorage {
  @override
  final DatabaseManager<Database> dbManager;

  FundSqliteStorage(this.dbManager);

  factory FundSqliteStorage.build(DependencyContainer c) {
    return FundSqliteStorage(c.get<DatabaseManager<Database>>());
  }

  @override
  Iterable<String> get columns => [
    "id",
    "note",
    "amount",
    "balance",
    "status",
    "category_id",
    "journal_id",
    "created_at",
    "updated_at",
    "released_at",
  ];

  @override
  Fund? Function(Row? r) get entityBuilder =>
      (Row? row) => Fund.tryRow(row);

  @override
  String get table => "funds";

  @override
  Function(Fund e) get valueBuilder =>
      (e) => [
        e.id,
        e.note,
        e.amount,
        e.balance,
        e.status,
        e.categoryId,
        e.journalId,
        e.createdAt,
        e.updatedAt,
        e.releasedAt,
      ];
}
