import 'package:banda/infra/db.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

typedef WithArgs = Set<String>;

class Repository {
  final Database db;
  Repository(this.db);
  static Future<Database> connect() => DB().connection;

  static String getId() {
    return Uuid().v4();
  }

  populateCategory(List<Map> mainRows) async {
    final List<String> categoryIds = mainRows
        .map((row) => row["category_id"] as String)
        .toList();
    final categoryRows = await getCategoryByIds(categoryIds);

    return mainRows.map((mainRow) {
      return {
        ...mainRow,
        "category": categoryRows.firstWhere(
          (categoryRow) => mainRow["category_id"] == categoryRow["id"],
        ),
      };
    }).toList();
  }

  populateAccount(List<Map> rows) async {
    final List<String> accountIds = rows
        .map((row) => row["account_id"] as String)
        .toList();
    final accountRows = await getAccountByIds(accountIds);

    return rows.map((mainRow) {
      return {
        ...mainRow,
        "account": accountRows.firstWhere(
          (accountRow) => mainRow["account_id"] == accountRow["id"],
        ),
      };
    }).toList();
  }

  populateEntityLabels(
    List<Map> rows,
    String junctionTable,
    String junctionKey,
  ) async {
    final List<String> ids = rows.map((row) => row["id"] as String).toList();

    final labelRows = await getEntityLabels(
      entityIds: ids,
      junctionTable: junctionTable,
      junctionKey: junctionKey,
    );

    return rows.map((row) {
      return {
        ...row,
        "labels": labelRows
            .where((labelRow) => labelRow[junctionKey] == row["id"])
            .toList(),
      };
    }).toList();
  }

  getAccountByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM accounts WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  getEntryByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM entries WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  getPartyByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM parties WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  getCategoryByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM categories WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  resetEntityLabels({
    required String entityId,
    required String junctionTable,
    required String junctionKey,
  }) async {
    db.execute(
      "DELETE FROM $junctionTable WHERE $junctionTable.$junctionKey = ?",
      [entityId],
    );
  }

  getEntityLabels({
    required List<String>? entityIds,
    required String junctionTable,
    required String junctionKey,
  }) async {
    if (entityIds == null || entityIds.isEmpty) return ResultSet([], [], []);

    final idsPlaceholder = entityIds.map((_) => "?").join(", ");
    final labelsQuery =
        """
      SELECT labels.*, $junctionTable.$junctionKey FROM labels
      INNER JOIN $junctionTable ON $junctionTable.label_id = labels.id
      WHERE $junctionTable.$junctionKey IN ($idsPlaceholder)
    """;

    final ResultSet rows = db.select(labelsQuery, entityIds);
    return rows;
  }

  Future<void> setEntityLabels({
    required String entityId,
    required List<String>? labelIds,
    required String junctionTable,
    required String junctionKey,
  }) async {
    if (labelIds == null || labelIds.isEmpty) return;

    await resetEntityLabels(
      entityId: entityId,
      junctionTable: junctionTable,
      junctionKey: junctionKey,
    );

    db.execute(
      "INSERT INTO $junctionTable ($junctionKey, label_id) VALUES ${labelIds.map((_) => '(?, ?)').join(",")}",
      labelIds
          .map((labelId) => [entityId, labelId])
          .expand((args) => args)
          .toList(),
    );
  }

  inExpr(List<String> value) {
    return value.map((_) => "?").join(",");
  }

  static begin() async {
    DB.beginTransaction();
  }

  static commit() async {
    DB.commit();
  }

  static rollback() async {
    DB.rollback();
  }

  static work<T>(Future<T> Function() callback) async {
    try {
      begin();
      final result = await callback();
      commit();
      return result;
    } catch (error) {
      rollback();
      rethrow;
    }
  }
}
