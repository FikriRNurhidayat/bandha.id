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
    "raised",
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
        e.raised,
        e.status.toString(),
        e.categoryId,
        e.journalId,
        e.createdAt.toIso8601String(),
        e.updatedAt.toIso8601String(),
        e.releasedAt?.toIso8601String(),
      ];

  @override
  Future<void> saveAll(Iterable<Fund> entities) async {
    super.saveAll(entities);
    final funds = entities.where((entry) => entry.labels.isNotEmpty);

    if (funds.isEmpty) return;

    final db = await dbManager.getInstance();
    db.execute(
      "DELETE FROM fund_labels WHERE fund_id IN (${funds.map((_) => "?").join(",")})",
      funds.map((e) => e.id).toList(),
    );
    db.execute(
      "INSERT INTO fund_labels (fund_id, label_id) VALUES ${funds.expand((e) => e.labels.map((l) => "(?, ?)")).join(", ")}",
      funds.expand((e) => e.labels.expand((l) => [e.id, l.id])).toList(),
    );
  }
}
