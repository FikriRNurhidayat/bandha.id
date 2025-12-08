import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/loan_payment.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/pair.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

class LoanRepository extends Repository {
  WithArgs withArgs;

  LoanRepository(super.db, {WithArgs? withArgs}) : withArgs = withArgs ?? {};

  LoanRepository withAccount() {
    withArgs.add("account");
    return this;
  }

  LoanRepository withEntry() {
    withArgs.add("entry");
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
      "INSERT INTO loans (id, kind, status, amount, fee, remainder, party_id, account_id, entry_id, issued_at, settled_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET kind = excluded.kind, status = excluded.status, amount = excluded.amount, fee = excluded.fee, remainder = excluded.remainder, party_id = excluded.party_id, account_id = excluded.account_id, entry_id = excluded.entry_id, issued_at = excluded.issued_at, settled_at = excluded.settled_at, updated_at = excluded.updated_at",
      [
        loan.id,
        loan.type.label,
        loan.status.label,
        loan.amount,
        loan.fee,
        loan.remainder,
        loan.partyId,
        loan.accountId,
        loan.entryId,
        loan.issuedAt.toIso8601String(),
        loan.settledAt?.toIso8601String(),
        loan.createdAt.toIso8601String(),
        loan.updatedAt.toIso8601String(),
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

    if (spec.containsKey("account_in")) {
      final value = spec["account_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.account_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (spec.containsKey("type_in")) {
      final value = spec["type_in"] as List<LoanType>;
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
    if (withArgs.contains("entry")) {
      final entryIds = rows.map((row) => row["entry_id"] as String).toList();
      final entryRows = await getEntryByIds(entryIds);
      rows = rows.map((row) {
        return {
          ...row,
          "entry": entryRows.firstWhere(
            (entryRow) => entryRow["id"] == row["entry_id"],
          ),
        };
      }).toList();
    }

    if (withArgs.contains("account")) {
      final accountIds = rows
          .map((row) => row["account_id"] as String)
          .toList();
      final accountRows = await getAccountByIds(accountIds);
      rows = rows.map((row) {
        return {
          ...row,
          "account": accountRows.firstWhere(
            (accountRow) => accountRow["id"] == row["account_id"],
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
          (row) => Loan.parse(row)
              .withEntry(Entry.tryRow(row["entry"]))
              .withParty(Party.tryRow(row["party"]))
              .withAccount(Account.tryRow(row["account"])),
        )
        .toList();
  }
}
