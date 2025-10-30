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

  Future<List<Loan>> search(Specification? specification) async {
    var baseQuery = "SELECT loans.* FROM loans";

    final query = makeQuery(baseQuery, specification);
    final sqlString = "${query.first} ORDER BY loans.issued_at DESC";
    final sqlArgs = query.second;

    final loanRows = db.select(sqlString, sqlArgs);

    return await entities(loanRows);
  }

  Future<Loan?> get(String id) async {
    final rows = db.select("SELECT * FROM loans WHERE id = ?", [id]);
    return entities(rows).then((loans) => loans.firstOrNull);
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM loans WHERE id = ?", [id]);
  }

  Pair<String, List<dynamic>> makeQuery(String baseQuery, Specification? spec) {
    var args = <dynamic>[];

    final where = whereQuery(spec);

    if (where != null && where["sql"].isNotEmpty) {
      baseQuery = "$baseQuery WHERE ${where["sql"]}";
      args = where["args"];
    }

    return Pair(baseQuery, args);
  }

  Map? whereQuery(Specification? spec) {
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
