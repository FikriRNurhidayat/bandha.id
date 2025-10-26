import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

class LoanRepository extends Repository {
  LoanRepository._(super.db);

  static Future<LoanRepository> build() async {
    final db = await Repository.connect();
    return LoanRepository._(db);
  }

  Future<List<Loan>> search(Map? spec) async {
    var select = "SELECT * FROM loans";
    var args = <dynamic>[];
    final where = _where(spec);
    if (where != null && where["sql"].isNotEmpty) {
      select = "$select WHERE ${where["sql"]}";
      args = where["args"];
    }
    final loanRows = db.select("$select ORDER BY issued_at DESC", args);
    return _populate(loanRows);
  }

  Future<Loan?> get(String id) async {
    final loanRows = db.select("SELECT * FROM loans WHERE id = ?", [id]);
    return (await _populate(loanRows)).firstOrNull;
  }

  Future<Loan> create({
    required double amount,
    required DateTime issuedAt,
    required DateTime settledAt,
    required LoanKind kind,
    required LoanStatus status,
    required String partyId,
    required String accountId,
    double? fee,
  }) async {
    final id = Repository.getId();
    final now = DateTime.now();
    return transaction<Loan>(() async {
      final loans = await _makeEntries(
        kind: kind,
        status: status,
        accountId: accountId,
        partyId: partyId,
        settledAt: settledAt,
        issuedAt: issuedAt,
        now: now,
        amount: amount,
      );

      final debit = loans["debit"];
      final credit = loans["credit"];

      await insertEntry(debit);
      await insertEntry(credit);

      db.execute(
        "INSERT INTO loans (id, amount, fee, status, kind, issued_at, account_id, party_id, debit_id, credit_id, created_at, updated_at, settled_at, deleted_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          id,
          amount,
          fee,
          status.label,
          kind.label,
          issuedAt.toIso8601String(),
          accountId,
          partyId,
          debit["id"],
          credit["id"],
          now.toIso8601String(),
          now.toIso8601String(),
          settledAt.toIso8601String(),
          null,
        ],
      );

      return Loan(
        id: id,
        kind: kind,
        status: status,
        amount: amount,
        partyId: partyId,
        accountId: accountId,
        issuedAt: issuedAt,
        settledAt: settledAt,
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  Future<void> update({
    required String id,
    required double amount,
    required DateTime issuedAt,
    required DateTime settledAt,
    required LoanKind kind,
    required LoanStatus status,
    required String partyId,
    required String accountId,
    double? fee,
  }) async {
    final now = DateTime.now();

    return transaction<void>(() async {
      final loanRows = db.select("SELECT * FROM loans WHERE id = ?", [id]);
      final entries = await _updateEntries(
        kind: kind,
        status: status,
        accountId: accountId,
        partyId: partyId,
        issuedAt: issuedAt,
        settledAt: settledAt,
        now: now,
        amount: amount,
        loanRow: loanRows.first,
      );

      final credit = entries["credit"];
      final debit = entries["debit"];

      final loanRow = Map.from(loanRows.first);
      loanRow["amount"] = amount;
      loanRow["fee"] = fee;
      loanRow["kind"] = kind.label;
      loanRow["status"] = status.label;
      loanRow["party_id"] = partyId;
      loanRow["account_id"] = accountId;
      loanRow["debit_id"] = debit["id"];
      loanRow["credit_id"] = credit["id"];
      loanRow["issued_at"] = issuedAt.toIso8601String();
      loanRow["settled_at"] = settledAt.toIso8601String();
      loanRow["updated_at"] = now.toIso8601String();

      await updateEntry(credit);
      await updateEntry(debit);
      await _updateLoan(loanRow);
    });
  }

  Future<void> remove(String id) async {
    return transaction<void>(() async {
      final loans = db.select("SELECT * FROM loans WHERE id = ?", [id]);
      if (loans.isEmpty) {
        return;
      }

      db.execute("DELETE FROM loans WHERE id = ?", [id]);
      db.execute("DELETE FROM loans WHERE id IN (?, ?)", [
        loans.first["debit_id"],
        loans.first["credit_id"],
      ]);
    });
  }

  Future<Map> _updateEntries({
    required LoanKind kind,
    required LoanStatus status,
    required String accountId,
    required String partyId,
    required DateTime issuedAt,
    required DateTime settledAt,
    required DateTime now,
    required double amount,
    required Map loanRow,
    double? fee,
  }) async {
    final category = await getCategoryByName(kind.label);
    if (category == null) {
      throw UnimplementedError();
    }

    final account = await getAccountById(accountId);
    if (account == null) {
      throw UnimplementedError();
    }

    final party = await getPartyById(partyId);
    if (party == null) {
      throw UnimplementedError();
    }

    final Map<String, dynamic> credit = {
      "id": loanRow["credit_id"],
      "note": kind == LoanKind.receiveable
          ? "Lent to ${party["name"]}"
          : "Paid to ${party["name"]}",
      "amount": (amount + (fee ?? 0)) * -1,
      "status": kind == LoanKind.receiveable
          ? EntryStatus.done.label
          : status.entryStatus().label,
      "readonly": true,
      "timestamp": kind == LoanKind.receiveable
          ? issuedAt.toIso8601String()
          : settledAt.toIso8601String(),
      "category_id": category["id"],
      "account_id": account["id"],
      "updated_at": now.toIso8601String(),
    };

    final Map<String, dynamic> debit = {
      "id": loanRow["debit_id"],
      "note": kind == LoanKind.debt
          ? "Borrowed from ${party["name"]}"
          : "Received from ${party["name"]}",
      "amount": amount,
      "status": kind == LoanKind.debt
          ? EntryStatus.done.label
          : status.entryStatus().label,
      "readonly": true,
      "timestamp": kind == LoanKind.debt
          ? issuedAt.toIso8601String()
          : settledAt.toIso8601String(),
      "category_id": category["id"],
      "account_id": account["id"],
      "updated_at": now.toIso8601String(),
    };

    return {"debit": debit, "credit": credit};
  }

  Future<Map> _makeEntries({
    required LoanKind kind,
    required LoanStatus status,
    required String accountId,
    required String partyId,
    required DateTime issuedAt,
    required DateTime settledAt,
    required DateTime now,
    required double amount,
    double? fee,
  }) async {
    final category = await getCategoryByName(kind.label);
    if (category == null) {
      throw UnimplementedError();
    }

    final account = await getAccountById(accountId);
    if (account == null) {
      throw UnimplementedError();
    }

    final party = await getPartyById(partyId);
    if (party == null) {
      throw UnimplementedError();
    }

    final Map<String, dynamic> credit = {
      "id": Repository.getId(),
      "note": kind == LoanKind.receiveable
          ? "Lent to ${party["name"]}"
          : "Paid to ${party["name"]}",
      "amount": (amount + (fee ?? 0)) * -1,
      "status": kind == LoanKind.receiveable
          ? EntryStatus.done.label
          : status.entryStatus().label,
      "readonly": true,
      "timestamp": kind == LoanKind.receiveable
          ? issuedAt.toIso8601String()
          : settledAt.toIso8601String(),
      "category_id": category["id"],
      "account_id": account["id"],
      "created_at": now.toIso8601String(),
      "updated_at": now.toIso8601String(),
    };

    final Map<String, dynamic> debit = {
      "id": Repository.getId(),
      "note": kind == LoanKind.debt
          ? "Borrowed from ${party["name"]}"
          : "Received from ${party["name"]}",
      "amount": amount,
      "status": kind == LoanKind.debt
          ? EntryStatus.done.label
          : status.entryStatus().label,
      "readonly": true,
      "timestamp": kind == LoanKind.debt
          ? issuedAt.toIso8601String()
          : settledAt.toIso8601String(),
      "category_id": category["id"],
      "account_id": account["id"],
      "created_at": now.toIso8601String(),
      "updated_at": now.toIso8601String(),
    };

    return {"debit": debit, "credit": credit};
  }

  Future<List<Loan>> _populate(ResultSet loanRows) async {
    final accountIds = loanRows
        .map((row) => row["account_id"] as String)
        .toList();
    final accountRows = await getAccountByIds(accountIds);

    final partyIds = loanRows.map((row) => row["party_id"] as String).toList();
    final partyRows = await getPartyByIds(partyIds);

    return loanRows.map((loanRow) {
      final loan = Loan.fromRow(loanRow);

      loan
          .setAccount(
            Account.fromRow(
              accountRows.firstWhere(
                (accountRow) => loanRow["account_id"] == accountRow["id"],
              ),
            ),
          )
          .setParty(
            Party.fromRow(
              partyRows.firstWhere(
                (partyRow) => loanRow["party_id"] == partyRow["id"],
              ),
            ),
          );

      return loan;
    }).toList();
  }

  Map? _where(Map? spec) {
    if (spec == null) return null;

    final Map<String, dynamic> where = {
      "args": <dynamic>[],
      "query": <String>[],
      "sql": null,
    };

    if (spec.containsKey("fee_lt")) {
      final value = spec["fee_lt"] as double;
      where["query"].add("loans.fee < ?");
      where["args"].add(value);
    }

    if (spec.containsKey("fee_lte")) {
      final value = spec["fee_lte"] as double;
      where["query"].add("loans.fee <= ?");
      where["args"].add(value);
    }

    if (spec.containsKey("fee_gt")) {
      final value = spec["fee_gt"] as double;
      where["query"].add("loans.fee > ?");
      where["args"].add(value);
    }

    if (spec.containsKey("fee_gte")) {
      final value = spec["fee_gte"] as double;
      where["query"].add("loans.fee >= ?");
      where["args"].add(value);
    }

    if (spec.containsKey("amount_lt")) {
      final value = spec["amount_lt"] as double;
      where["query"].add("loans.amount < ?");
      where["args"].add(value);
    }

    if (spec.containsKey("amount_lte")) {
      final value = spec["amount_lte"] as double;
      where["query"].add("loans.amount <= ?");
      where["args"].add(value);
    }

    if (spec.containsKey("amount_gt")) {
      final value = spec["amount_gt"] as double;
      where["query"].add("loans.amount > ?");
      where["args"].add(value);
    }

    if (spec.containsKey("amount_gte")) {
      final value = spec["amount_gte"] as double;
      where["query"].add("loans.amount >= ?");
      where["args"].add(value);
    }

    if (spec.containsKey("issued_between")) {
      final value = spec["issued_between"] as DateTimeRange;
      where["query"].add("(loans.issued_at BETWEEN ? AND ?)");
      where["args"].addAll([value.start, value.end]);
    }

    if (spec.containsKey("settled_between")) {
      final value = spec["settled_between"] as DateTimeRange;
      where["query"].add("(loans.settled_at BETWEEN ? AND ?)");
      where["args"].addAll([value.start, value.end]);
    }

    if (spec.containsKey("party_id_in")) {
      final value = spec["party_id_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.party_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (spec.containsKey("account_id_in")) {
      final value = spec["account_id_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.account_id IN (${value.map((_) => '?').join(', ')}))",
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

    if (spec.containsKey("category_id_in")) {
      final value = spec["category_id_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.category_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
    }

    if (spec.containsKey("category_id_ne")) {
      final value = spec["category_id_ne"] as String?;

      if (value != null && value.isNotEmpty) {
        where["query"].add("(loans.category_id != ?)");
        where["args"].add(value);
      }
    }

    where["sql"] = where["query"].join(" AND ");
    return where;
  }

  Future<void> _updateLoan(Map loan) async {
    db.execute(
      "UPDATE loans SET amount = ?, fee = ?, status = ?, kind = ?, issued_at = ?, account_id = ?, party_id = ?, debit_id = ?, credit_id = ?, updated_at = ?, settled_at = ? WHERE id = ?",
      [
        loan["amount"],
        loan["fee"],
        loan["status"],
        loan["kind"],
        loan["issued_at"],
        loan["account_id"],
        loan["party_id"],
        loan["debit_id"],
        loan["credit_id"],
        loan["updated_at"],
        loan["settled_at"],
        loan["id"],
      ],
    );
  }
}
