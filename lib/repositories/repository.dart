import 'package:banda/infra/store.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class Repository {
  final Database db;
  Repository(this.db);
  static Future<Database> connect() => Store().connection;

  static String getId() {
    return Uuid().v4();
  }

  static String getTime() {
    return DateTime.now().toIso8601String();
  }

  Future<List<Map>> populateCategory(List<Map> mainRows) async {
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

  Future<List<Map>> populateAccount(List<Map> mainRows) async {
    final List<String> accountIds = mainRows
        .map((row) => row["account_id"] as String)
        .toList();
    final accountRows = await getAccountByIds(accountIds);
    return mainRows.map((mainRow) {
      return {
        ...mainRow,
        "account": accountRows.firstWhere(
          (accountRow) => mainRow["account_id"] == accountRow["id"],
        ),
      };
    }).toList();
  }

  Future<List<Map>> populateLabels(
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

  Future<Row?> getTransferById(String id) async {
    final ResultSet rows = db.select("SELECT * FROM transfers WHERE id = ?", [
      id,
    ]);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<ResultSet> getAccountByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM accounts WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  Future<Row?> getAccountById(String id) async {
    final rows = await getAccountByIds([id]);
    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<ResultSet> getEntryByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM entries WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  Future<Row> getEntryById(String id) async {
    final rows = await getEntryByIds([id]);
    return rows.first;
  }

  Future<ResultSet> getPartyByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM parties WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  Future<Row> getPartyById(String id) async {
    final rows = await getPartyByIds([id]);
    return rows.first;
  }

  Future<ResultSet> getCategoryByIds(List<String> ids) async {
    return db.select(
      "SELECT * FROM categories WHERE id IN (${ids.map((_) => "?").join(", ")})",
      ids,
    );
  }

  Future<Map?> getCategoryById(String id) async {
    final rows = await getCategoryByIds([id]);
    return rows.first;
  }

  Future<Map?> getCategoryByName(String name) async {
    final ResultSet rows = db.select(
      "SELECT * FROM categories WHERE name = ?",
      [name],
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<void> updateEntry(Map entry, double deltaAmount) async {
    db.execute(
      "UPDATE entries SET note = ?, amount = ?, status = ?, readonly = ?, timestamp = ?, category_id = ?, account_id = ?, updated_at = ? WHERE id = ?",
      [
        entry["note"],
        entry["amount"],
        entry["status"],
        entry["readonly"],
        entry["timestamp"],
        entry["category_id"],
        entry["account_id"],
        entry["updated_at"],
        entry["id"],
      ],
    );

    await updateAccountBalance(entry["account_id"], deltaAmount);
  }

  Future<void> updateAccountBalance(String id, double amount) async {
    db.execute("UPDATE accounts SET balance = balance + ? WHERE id = ?", [
      amount,
      id,
    ]);
  }

  Future<void> insertEntry(Map entry) async {
    db.execute(
      "INSERT INTO entries (id, note, amount, status, readonly, timestamp, category_id, account_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [
        entry["id"],
        entry["note"],
        entry["amount"],
        entry["status"],
        entry["readonly"],
        entry["timestamp"],
        entry["category_id"],
        entry["account_id"],
        entry["created_at"],
        entry["updated_at"],
      ],
    );

    await updateAccountBalance(entry["account_id"], entry["amount"]);
  }

  Future<void> resetEntityLabels({
    required String entityId,
    required String junctionTable,
    required String junctionKey,
  }) async {
    db.execute(
      "DELETE FROM $junctionTable WHERE $junctionTable.$junctionKey = ?",
      [entityId],
    );
  }

  Future<ResultSet> getEntityLabels({
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

  static beginTransaction() async {
    Store.beginTransaction();
  }

  static commit() async {
    Store.commit();
  }

  static rollback() async {
    Store.rollback();
  }

  static Future<T> work<T>(Future<T> Function() callback) async {
    try {
      beginTransaction();
      final result = await callback();
      commit();
      return result;
    } catch (error) {
      rollback();
      rethrow;
    }
  }
}
