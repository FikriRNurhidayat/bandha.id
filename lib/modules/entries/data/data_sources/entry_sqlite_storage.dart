import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:bandha/infra/data/data_sources/sqlite_storage.dart';
import 'package:bandha/modules/entries/data/data_sources/entry_local_storage.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:sqlite3/sqlite3.dart';

class EntrySqliteStorage extends SqliteStorage<Entry>
    implements EntryLocalStorage {
  @override
  final DatabaseManager<Database> dbManager;

  EntrySqliteStorage(this.dbManager);

  factory EntrySqliteStorage.build(DependencyContainer c) {
    return EntrySqliteStorage(c.get<DatabaseManager<Database>>());
  }

  @override
  Iterable<String> get columns => [
    "id",
    "note",
    "amount",
    "status",
    "readonly",
    "category_id",
    "journal_id",
    "controller_id",
    "controller_type",
    "issued_at",
    "created_at",
    "updated_at",
  ];

  @override
  Entry? Function(Row? r) get entityBuilder =>
      (r) => Entry.tryRow(r);

  @override
  String get table => "entries";

  @override
  Function(Entry e) get valueBuilder =>
      (e) => [
        e.id,
        e.note,
        e.amount,
        e.status.toString(),
        e.readOnly,
        e.categoryId,
        e.journalId,
        e.controller?.id,
        e.controller?.type,
        e.issuedAt.toIso8601String(),
        e.createdAt.toIso8601String(),
        e.updatedAt.toIso8601String(),
      ];

  @override
  Future<DataList<Entry>> queryByControllable(
    Controllable controllable,
    DataQuery? query,
  ) {
    return queryByController(controllable.controller, query);
  }

  @override
  Future<DataList<Entry>> queryByController(
    Controller controller,
    DataQuery? query,
  ) {
    final dataQuery = query ?? DataQuery();

    dataQuery.filter
        .putIfAbsent("controller_id_eq", () => controller.id)
        .putIfAbsent("controller_type_eq", controller.type);

    return this.query(dataQuery);
  }

  @override
  Future<Iterable<Entry>> controllableBy(Controllable controllable) {
    return controlledBy(controllable.controller);
  }

  @override
  Future<Iterable<Entry>> controlledBy(Controller controller) {
    return findAll({
      "controller_id": controller.id,
      "controller_type": controller.type,
    });
  }
}
