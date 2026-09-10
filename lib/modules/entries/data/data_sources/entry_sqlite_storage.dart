import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:bandha/infra/data/data_sources/sqlite_storage.dart';
import 'package:bandha/modules/entries/data/data_sources/entry_local_storage.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/material.dart' hide Row;
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

  @override
  Future<void> saveAll(Iterable<Entry> entities) async {
    super.saveAll(entities);
    final entries = entities.where((entry) => entry.labels.isNotEmpty);

    if (entries.isEmpty) return;

    final db = await dbManager.getInstance();
    db.execute(
      "DELETE FROM entry_labels WHERE entry_id IN (${entries.map((_) => "?").join(",")})",
      entries.map((e) => e.id).toList(),
    );

    db.execute(
      "INSERT INTO entry_labels (entry_id, label_id) VALUES ${entries.expand((e) => e.labels.map((l) => "(?, ?)")).join(", ")}",
      entries.expand((e) => e.labels.expand((l) => [e.id, l.id])).toList(),
    );
  }

  @override
  Join joinBuilder(DataFilter? filter) {
    final join = Join();

    if (filter == null) return join;

    for (final key in filter.keys.toList()) {
      if (key.startsWith("journal.")) {
        join.expressions.add(
          "INNER JOIN journals ON journals.id = entries.journal_id",
        );
      } else if (key.startsWith("category.")) {
        join.expressions.add(
          "INNER JOIN categories ON categories.id = entries.category_id",
        );
      } else if (key.startsWith("labels.")) {
        join.expressions.addAll([
          "INNER JOIN entry_labels ON entry_labels.entry_id = entries.id",
          "INNER JOIN labels ON entry_labels.label_id = labels.id",
        ]);
      }
    }

    return join;
  }

  @override
  Where filterBuilder(DataFilter? filter) {
    final s = Where();

    if (filter == null) {
      return s;
    }

    debugPrint("filter[journal.asset_id_eq]: ${filter["journal.asset_id_eq"]}");

    return whereBuilder(
      s,
      Map.fromEntries(
        filter.entries.map(
          (entry) => MapEntry(switch (entry.key) {
            String key when key.startsWith("journal.") => key.replaceAll(
              "journal.",
              "journals.",
            ),
            String key when key.startsWith("category.") => key.replaceAll(
              "category.",
              "categories.",
            ),
            String key when key.startsWith("label.") => key.replaceAll(
              "label.",
              "labels.",
            ),
            _ => entry.key,
          }, entry.value),
        ),
      ),
    );
  }

  @override
  Future<Entry?> latestBy(DataFilter? filter) async {
    final db = await dbManager.getInstance();
    final join = joinBuilder(filter);
    final where = filterBuilder(filter);
    final ResultSet rows = db.select(
      "${whereSql(joinSql("SELECT $table.* FROM $table", join), where)} ORDER BY $table.created_at DESC LIMIT 1",
      where.toArguments(),
    );

    return entityBuilder(rows.first);
  }
}
