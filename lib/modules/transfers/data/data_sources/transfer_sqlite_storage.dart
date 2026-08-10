import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/infra/data/data_sources/sqlite_storage.dart';
import 'package:bandha/modules/transfers/data/data_sources/transfer_local_storage.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:sqlite3/sqlite3.dart';

class TransferSqliteStorage extends SqliteStorage<Transfer>
    implements TransferLocalStorage {
  @override
  final DatabaseManager<Database> dbManager;

  TransferSqliteStorage(this.dbManager);

  factory TransferSqliteStorage.build(DependencyContainer c) {
    return TransferSqliteStorage(c.get<DatabaseManager<Database>>());
  }

  @override
  Iterable<String> get columns => [
    "id",
    "note",
    "credit_id",
    "credit_fee_id",
    "debit_id",
    "debit_fee_id",
    "issued_at",
    "created_at",
    "updated_at",
  ];

  @override
  Transfer? Function(Row? r) get entityBuilder => throw UnimplementedError();

  @override
  String get table => "transfers";

  @override
  Function(Transfer e) get valueBuilder =>
      (e) => [
        e.id,
        e.note,
        e.creditId,
        e.creditFeeId,
        e.debitId,
        e.debitFeeId,
        e.issuedAt.toIso8601String(),
        e.createdAt.toIso8601String(),
        e.updatedAt.toIso8601String(),
      ];
}
