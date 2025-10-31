import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/pair.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

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

  save(Loan loan) async {
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

  Future<List<Loan>> search(Specification? specification) async {
    var baseQuery = "SELECT loans.* FROM loans";

    final query = defineQuery(baseQuery, specification);
    final sqlString = "${query.first} ORDER BY loans.issued_at DESC";
    final sqlArgs = query.second;

    final loanRows = db.select(sqlString, sqlArgs);

    return await entities(loanRows);
  }

  Future<Loan> get(String id) async {
    final rows = db.select("SELECT * FROM loans WHERE id = ?", [id]);
    return entities(rows).then((loans) => loans.first);
  }

  delete(String id) async {
    db.execute("DELETE FROM loans WHERE id = ?", [id]);
  }

  defineQuery(String baseQuery, Specification? spec) {
    var args = <dynamic>[];

    final where = whereQuery(spec);

    if (where != null && where["sql"].isNotEmpty) {
      baseQuery = "$baseQuery WHERE ${where["sql"]}";
      args = where["args"];
    }

    return Pair(baseQuery, args);
  }

  whereQuery(Specification? spec) {
    if (spec == null) return null;

    final Map<String, dynamic> where = {
      "args": <dynamic>[],
      "query": <String>[],
      "sql": null,
    };

    if (spec.containsKey("issued_between")) {
      final value = spec["issued_between"] as DateTimeRange;
      where["query"].add("(loans.issued_at BETWEEN ? AND ?)");
      where["args"].addAll([
        value.start.toIso8601String(),
        value.end.toIso8601String(),
      ]);
    }

    if (spec.containsKey("debit_account_in")) {
      final value = spec["debit_account_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.debit_account_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (spec.containsKey("credit_account_in")) {
      final value = spec["credit_account_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.credit_account_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (spec.containsKey("kind_in")) {
      final value = spec["kind_in"] as List<LoanKind>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.kind IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value.map((v) => v.label).toList());
      }
    }

    if (spec.containsKey("status_in")) {
      final value = spec["status_in"] as List<LoanStatus>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.status IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value.map((v) => v.label).toList());
      }
    }

    if (spec.containsKey("party_in")) {
      final value = spec["party_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.party_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (spec.containsKey("party_nin")) {
      final value = spec["party_nin"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.party_id NOT IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    where["sql"] = where["query"].join(" AND ");
    return where;
  }

  Future<List<Loan>> entities(List<Map> rows) async {
    if (withArgs.contains("entries")) {
      final entryIds = rows
          .expand(
            (row) => [row["debit_id"] as String, row["credit_id"] as String],
          )
          .toList();
      final entryRows = await getEntryByIds(entryIds);
      rows = rows.map((row) {
        return {
          ...row,
          "debit": entryRows.firstWhere((j) => j["id"] == row["debit_id"]),
          "credit": entryRows.firstWhere((j) => j["id"] == row["credit_id"]),
        };
      }).toList();
    }

    if (withArgs.contains("accounts")) {
      final accountIds = rows
          .expand(
            (i) => [
              i["debit_account_id"] as String,
              i["credit_account_id"] as String,
            ],
          )
          .toList();
      final accountRows = await getAccountByIds(accountIds);
      rows = rows.map((row) {
        return {
          ...row,
          "debit_account": accountRows.firstWhere(
            (accountRow) => accountRow["id"] == row["debit_account_id"],
          ),
          "credit_account": accountRows.firstWhere(
            (accountRow) => accountRow["id"] == row["credit_account_id"],
          ),
        };
      }).toList();
    }

    if (withArgs.contains("party")) {
      final partyIds = rows.map((row) => row["party_id"] as String).toList();
      final partyRows = await getPartyByIds(partyIds);
      rows = rows.map((row) {
        return {
          ...row,
          "party": partyRows.firstWhere(
            (partyRow) => partyRow["id"] == row["party_id"],
          ),
        };
      }).toList();
    }

    return rows
        .map(
          (row) => Loan.fromRow(row)
              .withParty(Party.tryRow(row["party"]))
              .withDebit(Entry.tryRow(row["debit"]))
              .withCredit(Entry.tryRow(row["credit"]))
              .withDebitAccount(Account.tryRow(row["debit_account"]))
              .withCreditAccount(Account.tryRow(row["credit_account"])),
        )
        .toList();
  }
}
