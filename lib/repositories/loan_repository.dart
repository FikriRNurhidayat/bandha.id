import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/specification.dart';

class LoanRepository extends Repository {
  WithArgs withArgs;

  LoanRepository(super.db, {WithArgs? withArgs}) : withArgs = withArgs ?? {};

  LoanRepository withAccounts() {
    withArgs.add("accounts");
    return this;
  }

  LoanRepository withEntries() {
    withArgs.add("entries");
    return this;
  }

  LoanRepository withParty() {
    withArgs.add("party");
    return this;
  }

  static Future<LoanRepository> build() async {
    final db = await Repository.connect();
    return LoanRepository(db);
  }

  Future<void> save(Loan loan) async {
    db.execute(
      "INSERT INTO loans (id, amount, fee, status, kind, issued_at, party_id, debit_id, credit_id, debit_account_id, credit_account_id, created_at, updated_at, settled_at, deleted_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET amount = excluded.amount, fee = excluded.fee, status = excluded.status, kind = excluded.kind, issued_at = excluded.issued_at, party_id = excluded.party_id, debit_id = excluded.debit_id, credit_id = excluded.credit_id, debit_account_id = excluded.debit_account_id, credit_account_id = excluded.credit_account_id, updated_at = excluded.updated_at, settled_at = excluded.settled_at, deleted_at = excluded.deleted_at",
      [
        loan.id,
        loan.amount,
        loan.fee,
        loan.status.label,
        loan.kind.label,
        loan.issuedAt.toIso8601String(),
        loan.partyId,
        loan.debitId,
        loan.creditId,
        loan.debitAccountId,
        loan.creditAccountId,
        loan.createdAt.toIso8601String(),
        loan.updatedAt.toIso8601String(),
        loan.settledAt.toIso8601String(),
        null,
      ],
    );
  }

  Future<List<Loan>> search(Specification? spec) async {
    final rows = db.select("SELECT * FROM loans ORDER BY issued_at DESC");
    return entities(rows);
  }

  Future<Loan?> get(String id) async {
    final rows = db.select("SELECT * FROM loans WHERE id = ?", [id]);
    return entities(rows).then((loans) => loans.firstOrNull);
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM loans WHERE id = ?", [id]);
  }

  Future<List<Loan>> entities(List<Map> loanRows) async {
    if (withArgs.contains("entries")) {
      final entryIds = loanRows
          .expand((i) => [i["debit_id"] as String, i["credit_id"] as String])
          .toList();
      final entryRows = await getEntryByIds(entryIds);
      loanRows = loanRows.map((i) {
        return {
          ...i,
          "debit": entryRows.firstWhere((j) => j["id"] == i["debit_id"]),
          "credit": entryRows.firstWhere((j) => j["id"] == i["credit_id"]),
        };
      }).toList();
    }

    if (withArgs.contains("accounts")) {
      final accountIds = loanRows
          .expand(
            (i) => [
              i["debit_account_id"] as String,
              i["credit_account_id"] as String,
            ],
          )
          .toList();
      final accountRows = await getAccountByIds(accountIds);
      loanRows = loanRows.map((i) {
        return {
          ...i,
          "debit_account": accountRows.firstWhere(
            (j) => j["id"] == i["debit_account_id"],
          ),
          "credit_account": accountRows.firstWhere(
            (j) => j["id"] == i["credit_account_id"],
          ),
        };
      }).toList();
    }

    if (withArgs.contains("party")) {
      final partyIds = loanRows.map((i) => i["party_id"] as String).toList();
      final partyRows = await getPartyByIds(partyIds);
      loanRows = loanRows.map((i) {
        return {
          ...i,
          "party": partyRows.firstWhere((j) => j["id"] == i["party_id"]),
        };
      }).toList();
    }

    return loanRows
        .map(
          (l) => Loan.fromRow(l)
              .withParty(Party.tryRow(l["party"]))
              .withDebit(Entry.tryRow(l["debit"]))
              .withCredit(Entry.tryRow(l["credit"]))
              .withDebitAccount(Account.tryRow(l["debit_account"]))
              .withCreditAccount(Account.tryRow(l["credit_account"])),
        )
        .toList();
  }
}
