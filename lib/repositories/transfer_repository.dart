import 'package:banda/entity/entry.dart';
import 'package:banda/entity/transfer.dart';
import 'package:banda/repositories/repository.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class TransferRepository extends Repository {
  TransferRepository._(super.db);

  static Future<TransferRepository> build() async {
    final db = await Repository.connect();
    return TransferRepository._(db);
  }

  Future<Transfer?> create({
    required double amount,
    required DateTime timestamp,
    required String fromId,
    required String toId,
    double? fee,
  }) async {
    final id = Repository.getId();
    final now = DateTime.now();

    try {
      db.execute("BEGIN TRANSACTION");
      final preps = await _prepareTransfer(
        fromId: fromId,
        toId: toId,
        timestamp: timestamp,
        now: now,
        amount: amount,
        fee: fee,
      );

      final fromEntry = preps["fromEntry"];
      final toEntry = preps["toEntry"];
      final note = preps["note"];

      await _insertEntry(fromEntry);
      await _insertEntry(toEntry);

      db.execute(
        "INSERT INTO transfers (id, note, amount, fee, timestamp, from_entry_id, to_entry_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          id,
          note,
          amount,
          fee,
          timestamp.toIso8601String(),
          fromEntry["id"],
          toEntry["id"],
          now.toIso8601String(),
          now.toIso8601String(),
        ],
      );

      db.execute('COMMIT');
    } catch (error) {
      db.execute('ROLLBACK');
    }

    return get(id);
  }

  Future<Transfer?> update({
    required String id,
    required double amount,
    required DateTime timestamp,
    required String fromId,
    required String toId,
    double? fee,
  }) async {
    final now = DateTime.now();

    try {
      db.execute("BEGIN TRANSACTION");
      final currentTransfer = await _getTransfer(id);
      if (currentTransfer == null) return null;

      final preps = await _prepareTransfer(
        fromId: fromId,
        toId: toId,
        timestamp: timestamp,
        now: now,
        amount: amount,
        fee: fee,
      );

      final fromEntry = preps["fromEntry"];
      final toEntry = preps["toEntry"];
      final note = preps["note"];

      db.execute("DELETE FROM entries WHERE id IN (?, ?)", [
        currentTransfer["from_entry_id"],
        currentTransfer["to_entry_id"],
      ]);

      await _insertEntry(fromEntry);
      await _insertEntry(toEntry);

      db.execute(
        "UPDATE transfers SET note = ?, amount = ?, fee = ?, from_entry_id = ?, to_entry_id = ?,timestamp = ?, updated_at = ? WHERE id = ?",
        [
          note,
          amount,
          fee,
          fromEntry["id"],
          toEntry["id"],
          timestamp.toIso8601String(),
          now.toIso8601String(),
          id,
        ],
      );

      db.execute("COMMIT");

      return get(id);
    } catch (error) {
      db.execute("ROLLBACK");
      return null;
    }
  }

  Future<Transfer?> get(String id) async {
    final ResultSet rows = db.select(
      """
      SELECT
        transfers.id,
        transfers.note,
        transfers.amount,
        transfers.fee,
        transfers.timestamp,
        from_accounts.id AS from_account_id,
        from_accounts.name AS from_account_name,
        from_accounts.holder_name AS from_account_holder_name,
        to_accounts.id AS to_account_id,
        to_accounts.name AS to_account_name,
        to_accounts.holder_name AS to_account_holder_name,
        transfers.created_at,
        transfers.updated_at
      FROM transfers
      INNER JOIN entries AS from_entries ON from_entries.id = transfers.from_entry_id 
      INNER JOIN accounts AS from_accounts ON from_accounts.id = from_entries.account_id 
      INNER JOIN entries AS to_entries ON to_entries.id = transfers.to_entry_id 
      INNER JOIN accounts AS to_accounts ON to_accounts.id = to_entries.account_id 
      WHERE transfers.id = ?
      """,
      [id],
    );

    if (rows.isEmpty) {
      return null;
    }

    return Transfer.fromRow(rows.first);
  }

  Future<List<Transfer>> search() async {
    final ResultSet rows = db.select("""
        SELECT
          transfers.id,
          transfers.note,
          transfers.amount,
          transfers.fee,
          transfers.timestamp,
          from_accounts.id AS from_account_id,
          from_accounts.name AS from_account_name,
          from_accounts.holder_name AS from_account_holder_name,
          to_accounts.id AS to_account_id,
          to_accounts.name AS to_account_name,
          to_accounts.holder_name AS to_account_holder_name,
          transfers.created_at,
          transfers.updated_at
        FROM transfers
        INNER JOIN entries AS from_entries ON from_entries.id = transfers.from_entry_id 
        INNER JOIN accounts AS from_accounts ON from_accounts.id = from_entries.account_id 
        INNER JOIN entries AS to_entries ON to_entries.id = transfers.to_entry_id 
        INNER JOIN accounts AS to_accounts ON to_accounts.id = to_entries.account_id 
        ORDER BY transfers.timestamp DESC
        """);

    return rows.map((row) => Transfer.fromRow(row)).toList();
  }

  Future<void> delete(String id) async {
    try {
      db.execute("BEGIN TRANSACTION");

      final ResultSet rows = db.select("SELECT * FROM transfers WHERE id = ?", [
        id,
      ]);

      if (rows.isEmpty) {
        db.execute("COMMIT");
        return;
      }

      final row = rows.first;

      db.execute("DELETE FROM transfers WHERE id = ?", [id]);
      db.execute("DELETE FROM entries WHERE id IN (?, ?)", [
        row["from_entry_id"],
        row["to_entry_id"],
      ]);

      db.execute("COMMIT");
    } catch (e) {
      db.execute("ROLLBACK");
    }
  }

  Future<Map?> _getCategoryByName(String name) async {
    final ResultSet rows = db.select(
      "SELECT * FROM categories WHERE name = ?",
      [name],
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<Map?> _getAccount(String id) async {
    final ResultSet rows = db.select("SELECT * FROM accounts WHERE id = ?", [
      id,
    ]);

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  Future<Map?> _getTransfer(String id) async {
    final ResultSet rows = db.select("SELECT * FROM transfers WHERE id = ?", [
      id,
    ]);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<Map> _prepareTransfer({
    required String fromId,
    required String toId,
    required DateTime timestamp,
    required DateTime now,
    required double amount,
    double? fee,
  }) async {
    final category = await _getCategoryByName("Transfer");
    if (category == null) {
      throw UnimplementedError();
    }

    final fromAccount = await _getAccount(fromId);
    if (fromAccount == null) {
      throw UnimplementedError();
    }

    final toAccount = await _getAccount(toId);
    if (toAccount == null) {
      throw UnimplementedError();
    }

    final fromName = "${fromAccount["name"]} — ${fromAccount["holder_name"]}";
    final toName = "${toAccount["name"]} — ${toAccount["holder_name"]}";

    final note = "Transfer from $fromName to $toName";

    final Map<String, dynamic> fromEntry = {
      "id": Uuid().v4(),
      "note": "Transfer to $toName",
      "amount": (amount + (fee ?? 0)) * -1,
      "status": EntryStatus.done.label,
      "readonly": true,
      "timestamp": timestamp.toIso8601String(),
      "category_id": category["id"],
      "account_id": fromAccount["id"],
      "created_at": now.toIso8601String(),
      "updated_at": now.toIso8601String(),
    };

    final Map<String, dynamic> toEntry = {
      "id": Uuid().v4(),
      "note": "Transfer from $fromName",
      "amount": amount,
      "status": EntryStatus.done.label,
      "readonly": true,
      "timestamp": timestamp.toIso8601String(),
      "category_id": category["id"],
      "account_id": toAccount["id"],
      "created_at": now.toIso8601String(),
      "updated_at": now.toIso8601String(),
    };

    return {"fromEntry": fromEntry, "toEntry": toEntry, "note": note};
  }

  Future<void> _insertEntry(Map entry) async {
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
  }
}
