import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/transfer.dart';
import 'package:banda/repositories/repository.dart';
import 'package:sqlite3/sqlite3.dart';

class TransferRepository extends Repository {
  Set<String> withOpts;

  TransferRepository(super.db, {Set<String>? withOpts})
    : withOpts = withOpts ?? {};

  static Future<TransferRepository> build() async {
    final db = await Repository.connect();
    return TransferRepository(db);
  }

  TransferRepository withAccounts() {
    withOpts.add("accounts");
    return TransferRepository(db, withOpts: withOpts);
  }

  TransferRepository withEntries() {
    withOpts.add("entries");
    return TransferRepository(db, withOpts: withOpts);
  }

  Future<void> save(Transfer transfer) async {
    db.execute(
      "INSERT INTO transfers (id, note, amount, fee, debit_id, debit_account_id, credit_id, credit_account_id, issued_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET note = excluded.note, amount = excluded.amount, fee = excluded.fee, debit_id = excluded.debit_id, debit_account_id = excluded.debit_account_id, credit_id = excluded.credit_id, credit_account_id = excluded.credit_account_id, issued_at = excluded.issued_at, updated_at = excluded.updated_at",
      [
        transfer.id,
        transfer.note,
        transfer.amount,
        transfer.fee,
        transfer.debitId,
        transfer.debitAccountId,
        transfer.creditId,
        transfer.creditAccountId,
        transfer.issuedAt.toIso8601String(),
        transfer.createdAt.toIso8601String(),
        transfer.updatedAt.toIso8601String(),
      ],
    );
  }

  Future<Transfer?> get(String id) async {
    final ResultSet rows = db.select(
      "SELECT * FROM transfers WHERE transfers.id = ?",
      [id],
    );

    return populate(rows).then((rows) => rows.firstOrNull);
  }

  Future<List<Transfer>> search() async {
    final ResultSet rows = db.select("SELECT * FROM transfers");
    return populate(rows).then((rows) => rows.toList());
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM transfers WHERE id = ?", [id]);
  }

  Future<List<Transfer>> populate(List<Map> transferRows) async {
    if (withOpts.contains("accounts")) {
      final accountIds = transferRows
          .expand(
            (t) => [
              t["debit_account_id"] as String,
              t["credit_account_id"] as String,
            ],
          )
          .toList();
      final accountRows = await getAccountByIds(accountIds);

      transferRows = transferRows.map((t) {
        return {
          ...t,
          "debit_account": accountRows.firstWhere(
            (e) => e["id"] == t["debit_account_id"],
          ),
          "credit_account": accountRows.firstWhere(
            (e) => e["id"] == t["credit_account_id"],
          ),
        };
      }).toList();
    }

    if (withOpts.contains("entries")) {
      final entryIds = transferRows
          .expand((t) => [t["debit_id"] as String, t["credit_id"] as String])
          .toList();
      final entryRows = await getEntryByIds(entryIds);

      transferRows = transferRows.map((t) {
        return {
          ...t,
          "debit": entryRows.firstWhere((e) => e["id"] == t["debit_id"]),
          "credit": entryRows.firstWhere((e) => e["id"] == t["credit_id"]),
        };
      }).toList();
    }

    return transferRows.map((e) {
      return Transfer.fromRow(e)
          .withDebit(Entry.fromRow(e["debit"]))
          .withDebitAccount(Account.fromRow(e["debit_account"]))
          .withCredit(Entry.fromRow(e["credit"]))
          .withCreditAccount(Account.fromRow(e["credit_account"]));
    }).toList();
  }
}
