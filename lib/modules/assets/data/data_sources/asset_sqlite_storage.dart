import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/data_sources/sqlite_storage.dart';
import 'package:bandha/modules/assets/data/data_sources/asset_local_storage.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:sqlite3/sqlite3.dart';

class AssetSqliteStorage extends SqliteStorage<Asset>
    implements AssetLocalStorage {
  @override
  final DatabaseManager<Database> dbManager;

  @override
  final table = "assets";

  AssetSqliteStorage(this.dbManager);

  factory AssetSqliteStorage.fromContainer(DependencyContainer c) {
    return AssetSqliteStorage(c.get<DatabaseManager<Database>>());
  }

  @override
  Future<void> balance(String id) {
    throw UnimplementedError();
  }

  @override
  Iterable<String> get columns => [
    "id",
    "name",
    "code",
    "balance",
    "created_at",
    "updated_at",
  ];

  @override
  Asset? Function(Row? r) get entityBuilder =>
      (r) => Asset.tryRow(r);

  @override
  Function(Asset e) get valueBuilder =>
      (e) => [
        e.id,
        e.name,
        e.code,
        e.balance,
        e.createdAt.toIso8601String(),
        e.updatedAt.toIso8601String(),
      ];
}
