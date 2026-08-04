import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/data/data_sources/classifier_sqlite_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/label_local_storage.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:sqlite3/sqlite3.dart';

class LabelSqliteStorage extends ClassifierSqliteStorage<Label>
    implements LabelLocalStorage {
  @override
  final DatabaseManager<Database> dbManager;

  LabelSqliteStorage(this.dbManager);

  factory LabelSqliteStorage.fromContainer(DependencyContainer c) {
    return LabelSqliteStorage(c.get<DatabaseManager<Database>>());
  }

  @override
  Future<Map<String, Iterable<Label>>> groupByEntryIds(
    Iterable<String> entryIds,
  ) async {
    final db = await dbManager.getInstance();
    final ResultSet rows = db.select(
      "SELECT labels.*, entry_labels.entry_id FROM labels JOIN entry_labels ON entry_labels.label_id = labels.id WHERE entry_labels.entry_id IN (${entryIds.map((_) => "?").join(", ")})",
      entryIds.toList(),
    );

    return rows.fold<Map<String, List<Label>>>(<String, List<Label>>{}, (
      map,
      row,
    ) {
      if (map.containsKey(row["entry_id"])) {
        map["entry_id"]!.add(Label.fromRow(row));
      } else {
        map.putIfAbsent(row["entry_id"], () => <Label>[Label.fromRow(row)]);
      }

      return map;
    });
  }

  @override
  Future<Map<String, Iterable<Label>>> groupByFundIds(
    Iterable<String> fundIds,
  ) async {
    final db = await dbManager.getInstance();
    final ResultSet rows = db.select(
      "SELECT labels.*, fund_labels.fund_id FROM labels JOIN fund_labels ON fund_labels.label_id = labels.id WHERE fund_labels.fund_id IN (${fundIds.map((_) => "?").join(", ")})",
      fundIds.toList(),
    );

    return rows.fold<Map<String, List<Label>>>(<String, List<Label>>{}, (
      map,
      row,
    ) {
      if (map.containsKey(row["fund_id"])) {
        map["fund_id"]!.add(Label.fromRow(row));
      } else {
        map.putIfAbsent(row["fund_id"], () => <Label>[Label.fromRow(row)]);
      }

      return map;
    });
  }

  @override
  Iterable<String> get columns => [
    "id",
    "name",
    "readonly",
    "created_at",
    "updated_at",
  ];

  @override
  Label? Function(Row? r) get entityBuilder =>
      (r) => Label.tryRow(r);

  @override
  Function(Label e) get valueBuilder =>
      (e) => [
        e.id,
        e.name,
        e.readOnly,
        e.createdAt.toIso8601String(),
        e.updatedAt.toIso8601String(),
      ];

  @override
  String get table => "labels";
}
