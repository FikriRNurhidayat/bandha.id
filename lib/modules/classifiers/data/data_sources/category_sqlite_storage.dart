import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/data/data_sources/category_local_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/classifier_sqlite_storage.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:sqlite3/sqlite3.dart';

class CategorySqliteStorage extends ClassifierSqliteStorage<Category>
    implements CategoryLocalStorage {
  @override
  final DatabaseManager<Database> dbManager;

  CategorySqliteStorage(this.dbManager);

  factory CategorySqliteStorage.fromContainer(DependencyContainer c) {
    return CategorySqliteStorage(c.get<DatabaseManager<Database>>());
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
  Category? Function(Row? r) get entityBuilder =>
      (r) => Category.tryRow(r);

  @override
  String get table => "categories";

  @override
  Function(Category e) get valueBuilder =>
      (e) => [
        e.id,
        e.name,
        e.readOnly,
        e.createdAt.toIso8601String(),
        e.updatedAt.toIso8601String(),
      ];
}
