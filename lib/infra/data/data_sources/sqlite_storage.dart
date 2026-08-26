import 'package:bandha/core/data/data_sources/local_storage.dart';
import 'package:bandha/core/data/database_manager.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';

abstract class SqliteStorage<T extends Entity> implements LocalStorage<T> {
  abstract final String table;
  abstract final Iterable<String> columns;
  abstract final DatabaseManager<Database> dbManager;
  abstract final Function(T e) valueBuilder;
  abstract final T? Function(Row? r) entityBuilder;

  Function(Where s, String o, dynamic v)? expressionBuilder;

  @override
  Future<void> destroy(T entity) {
    debugPrint('SqliteStorage.destroy - entity.id: ${entity.id}');
    return destroyAll([entity]);
  }

  @override
  Future<void> destroyAll(Iterable<T> entities) async {
    debugPrint("SqliteStorage/destroyAll");
    final db = await dbManager.getInstance();
    db.execute(
      "DELETE FROM $table WHERE id IN (${entities.map((e) => "?").join(",")});",
      entities.map((e) => e.id).toList(),
    );
  }

  @override
  Future<void> save(T entity) {
    debugPrint("SqliteStorage/save");
    return saveAll([entity]);
  }

  @override
  Future<void> saveAll(Iterable<T> entities) async {
    debugPrint("SqliteStorage/saveAll");
    final db = await dbManager.getInstance();
    final columnSql = columns.join(", ");
    final valuesSql = entities
        .map((e) => "(${columns.map((c) => "?").join(", ")})")
        .join(", ");
    final doUpdateSql = columns
        .where((c) => c != "id" && c != "created_at")
        .map((c) => "$c = excluded.$c")
        .join(", ");

    db.execute(
      "INSERT INTO $table ($columnSql) VALUES $valuesSql ON CONFLICT DO UPDATE SET $doUpdateSql;",
      entities.expand((e) => valueBuilder(e)).toList(),
    );
  }

  @override
  Future<T?> find(DataFilter filter) async {
    debugPrint("SqliteStorage/find");
    final db = await dbManager.getInstance();
    final join = joinBuilder(filter);
    final where = filterBuilder(filter);
    final ResultSet rows = db.select(
      "${whereSql(joinSql("SELECT $table.* FROM $table", join), where)} LIMIT 1",
      where.toArguments(),
    );

    return entityBuilder(rows.first);
  }

  @override
  Future<Iterable<T>> findAll(DataFilter filter) async {
    debugPrint("SqliteStorage/findAll");
    final db = await dbManager.getInstance();
    final join = joinBuilder(filter);
    final where = filterBuilder(filter);
    final ResultSet rows = db.select(
      whereSql(joinSql("SELECT $table.* FROM $table", join), where),
      where.toArguments(),
    );

    return rows.map((row) => entityBuilder(row)).whereType<T>();
  }

  @override
  Future<DataList<T>> query(DataQuery query) async {
    try {
      final db = await dbManager.getInstance();
      final join = joinBuilder(query.filter);
      final where = filterBuilder(query.filter);
      final sql = whereSql(joinSql("SELECT $table.* FROM $table", join), where);
      final ResultSet rows = db.select(sql, where.toArguments());
      final entities = rows.map((row) => entityBuilder(row)).whereType<T>();

      return DataList(
        hasNext: (entities.length) < query.size,
        hasPrevious: query.cursor != null,
        hits: entities,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print(error);
        print(stackTrace);
      }

      rethrow;
    }
  }

  Where filterBuilder(DataFilter? filter) {
    final s = Where();

    if (filter == null) {
      return s;
    }

    return whereBuilder(s, filter);
  }

  Where whereBuilder(Where s, DataFilter filter) {
    for (final MapEntry(key: o, value: v) in filter.entries) {
      if (o.endsWith("_eq")) {
        final f = o.replaceFirst(RegExp(r'_eq$'), '');
        s.sql.add("$f = ?");
        s.args.add(v);
      } else if (o.endsWith("_like")) {
        final f = o.replaceFirst(RegExp(r'_like$'), '');
        s.sql.add("$f LIKE ?");
        s.args.add("%$v%");
      } else if (o.endsWith("_ne")) {
        final f = o.replaceFirst(RegExp(r'_ne$'), '');
        s.sql.add("$f != ?");
        s.args.add(v);
      } else if (o.endsWith("_gt")) {
        final f = o.replaceFirst(RegExp(r'_gt$'), '');
        s.sql.add("$f > ?");
        s.args.add(v);
      } else if (o.endsWith("_gte")) {
        final f = o.replaceFirst(RegExp(r'_gte$'), '');
        s.sql.add("$f >= ?");
        s.args.add(v);
      } else if (o.endsWith("_lt")) {
        final f = o.replaceFirst(RegExp(r'_lt$'), '');
        s.sql.add("$f < ?");
        s.args.add(v);
      } else if (o.endsWith("_lte")) {
        final f = o.replaceFirst(RegExp(r'_lte$'), '');
        s.sql.add("$f <= ?");
        s.args.add(v);
      } else if (o.endsWith("_in")) {
        final f = o.replaceFirst(RegExp(r'_in$'), '');
        if (v is Iterable<dynamic>) {
          s.sql.add("$f IN (${v.map((v) => "?").join(", ")})");
          s.args.addAll(v);
        }
      } else if (o.endsWith("_nin")) {
        final f = o.replaceFirst(RegExp(r'_nin$'), '');
        if (v is Iterable<dynamic>) {
          s.sql.add("$f NOT IN (${v.map((v) => "?").join(", ")})");
          s.args.addAll(v);
        }
      } else if (o.endsWith("_between")) {
        final f = o.replaceFirst(RegExp(r'_between$'), '');
        if (v is Iterable<dynamic>) {
          s.sql.add("$f BETWEEN ? AND ?");
          s.args.addAll(v);
        }
      }
    }

    return s;
  }

  String whereSql(String sql, Where where) {
    if (where.isEmpty) {
      return sql;
    }
    final result = "$sql WHERE ${where.toSql()}";
    return result;
  }

  Join joinBuilder(DataFilter? filter) {
    return Join();
  }

  String joinSql(String sql, Join join) {
    if (join.expressions.isEmpty) {
      return sql;
    }

    return "$sql ${join.toSql()}";
  }
}

class Join {
  final List<String> expressions = [];

  String toSql() {
    return expressions.join(" ");
  }

  Join();
}

class Where {
  final List<String> sql = [];
  final List<dynamic> args = [];

  bool get isEmpty => sql.isEmpty;

  List<dynamic> toArguments() {
    return args;
  }

  String toSql() {
    return sql.map((sql) => "($sql)").join(" AND ");
  }

  Where();
}
