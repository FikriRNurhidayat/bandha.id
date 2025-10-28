import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/party.dart';
import 'package:banda/repositories/repository.dart';
import 'package:flutter/material.dart';

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
    final rows = db.select("$select ORDER BY issued_at DESC", args);
    return populate(rows);
  }

  Future<Loan?> get(String id) async {
    final rows = db.select("SELECT * FROM loans WHERE id = ?", [id]);
    return populate(rows).then((loans) => loans.firstOrNull);
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
    return Repository.work<Loan>(() async {
      final loans = await makeEntries(
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

    return Repository.work<void>(() async {
      final loan = Map.from(
        db.select("SELECT * FROM loans WHERE id = ?", [id]).first,
      );

      final entries = await makeUpdatedEntries(
        kind: kind,
        status: status,
        accountId: accountId,
        partyId: partyId,
        issuedAt: issuedAt,
        settledAt: settledAt,
        now: now,
        amount: amount,
        loanRow: loan,
      );

      final nextCredit = entries["credit"];
      final initCredit = await getEntryById(nextCredit["id"]);
      final nextDebit = entries["debit"];
      final initDebit = await getEntryById(nextDebit["id"]);
      final debitDelta = nextDebit["amount"] - initDebit["amount"];
      final creditDelta = nextCredit["amount"] - initCredit["amount"];

      loan["amount"] = amount;
      loan["fee"] = fee;
      loan["kind"] = kind.label;
      loan["status"] = status.label;
      loan["party_id"] = partyId;
      loan["account_id"] = accountId;
      loan["debit_id"] = nextDebit["id"];
      loan["credit_id"] = nextCredit["id"];
      loan["issued_at"] = issuedAt.toIso8601String();
      loan["settled_at"] = settledAt.toIso8601String();
      loan["updated_at"] = now.toIso8601String();

      await updateEntry(nextCredit, creditDelta);
      await updateEntry(nextDebit, debitDelta);
      await updateLoan(loan);
    });
  }

  Future<void> remove(String id) async {
    return Repository.work<void>(() async {
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

  Future<Map> makeUpdatedEntries({
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
    final account = await getAccountById(accountId);
    final party = await getPartyById(partyId);

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
      "category_id": category!["id"],
      "account_id": account!["id"],
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

  Future<Map> makeEntries({
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
    final account = await getAccountById(accountId);
    final party = await getPartyById(partyId);

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
      "category_id": category!["id"],
      "account_id": account!["id"],
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

  Future<List<Map>> populateParties(List<Map> rows) async {
    final partyIds = rows.map((row) => row["party_id"] as String).toList();
    final partyRows = await getPartyByIds(partyIds);
    return rows.map((row) {
      row["party"] = partyRows.firstWhere(
        (partyRow) => partyRow["id"] == row["party_id"],
      );
      return row;
    }).toList();
  }

  Future<List<Loan>> populate(List<Map> rows) async {
    return populateAccount(rows).then((rows) => populateParties(rows)).then((
      rows,
    ) {
      return rows
          .map(
            (row) => Loan.fromRow(row)
                .setAccount(Account.fromRow(row["account"]))
                .setParty(Party.fromRow(row["party"])),
          )
          .toList();
    });
  }

  Future<void> updateLoan(Map loan) async {
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

    if (spec.containsKey("party_in")) {
      final value = spec["party_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loans.party_id IN (${value.map((_) => '?').join(', ')}))",
        );
        where["args"].addAll(value);
      }
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

    if (spec.containsKey("category_in")) {
      final value = spec["category_in"] as List<String>;
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
}
