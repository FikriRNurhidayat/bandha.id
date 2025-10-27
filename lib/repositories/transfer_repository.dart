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

    return atomic<Transfer?>(() async {
      final entries = await _makeEntries(
        fromId: fromId,
        toId: toId,
        timestamp: timestamp,
        now: now,
        amount: amount,
        fee: fee,
      );

      final from = entries["fromEntry"];
      final to = entries["toEntry"];
      final note = entries["note"];

      await insertEntry(from);
      await insertEntry(to);

      db.execute(
        "INSERT INTO transfers (id, note, amount, fee, timestamp, from_entry_id, to_entry_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          id,
          note,
          amount,
          fee,
          timestamp.toIso8601String(),
          from["id"],
          to["id"],
          now.toIso8601String(),
          now.toIso8601String(),
        ],
      );

      return get(id);
    });
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

    return atomic<Transfer?>(() async {
      final transfer = await getTransferById(id);
      final initFromEntry = await getEntryById(transfer!["from_entry_id"]);
      final initToEntry = await getEntryById(transfer["to_entry_id"]);

      final entries = await makeEntries(
        transfer: transfer,
        fromId: fromId,
        toId: toId,
        timestamp: timestamp,
        now: now,
        amount: amount,
        fee: fee,
      );

      final nextFromEntry = entries["fromEntry"];
      final nextToEntry = entries["toEntry"];
      final note = entries["note"];

      await updateEntry(
        nextFromEntry,
        nextFromEntry["amount"] - initFromEntry["amount"],
      );

      await updateEntry(
        nextToEntry,
        nextToEntry["amount"] - initToEntry["amount"],
      );

      db.execute(
        "UPDATE transfers SET note = ?, amount = ?, fee = ?, from_entry_id = ?, to_entry_id = ?,timestamp = ?, updated_at = ? WHERE id = ?",
        [
          note,
          amount,
          fee,
          nextFromEntry["id"],
          nextToEntry["id"],
          timestamp.toIso8601String(),
          now.toIso8601String(),
          id,
        ],
      );

      return get(id);
    });
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

  Future<Map> makeEntries({
    required Map transfer,
    required String fromId,
    required String toId,
    required DateTime timestamp,
    required DateTime now,
    required double amount,
    double? fee,
  }) async {
    final category = await getCategoryByName("Transfer");
    final fromAccount = await getAccountById(fromId);
    final toAccount = await getAccountById(toId);

    final fromName = "${fromAccount!["name"]} — ${fromAccount["holder_name"]}";
    final toName = "${toAccount!["name"]} — ${toAccount["holder_name"]}";

    final note = "Transfer from $fromName to $toName";

    final Map<String, dynamic> fromEntry = {
      "id": transfer["from_entry_id"],
      "note": "Transfered to $toName",
      "amount": (amount + (fee ?? 0)) * -1,
      "status": EntryStatus.done.label,
      "readonly": true,
      "timestamp": timestamp.toIso8601String(),
      "category_id": category!["id"],
      "account_id": fromAccount["id"],
      "updated_at": now.toIso8601String(),
    };

    final Map<String, dynamic> toEntry = {
      "id": transfer["to_entry_id"],
      "note": "Received from $fromName",
      "amount": amount,
      "status": EntryStatus.done.label,
      "readonly": true,
      "timestamp": timestamp.toIso8601String(),
      "category_id": category["id"],
      "account_id": toAccount["id"],
      "updated_at": now.toIso8601String(),
    };

    return {"fromEntry": fromEntry, "toEntry": toEntry, "note": note};
  }

  Future<Map> _makeEntries({
    required String fromId,
    required String toId,
    required DateTime timestamp,
    required DateTime now,
    required double amount,
    double? fee,
  }) async {
    final category = await getCategoryByName("Transfer");
    if (category == null) {
      throw UnimplementedError();
    }

    final fromAccount = await getAccountById(fromId);
    if (fromAccount == null) {
      throw UnimplementedError();
    }

    final toAccount = await getAccountById(toId);
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
}
