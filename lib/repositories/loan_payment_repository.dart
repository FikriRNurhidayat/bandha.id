import 'package:banda/entity/account.dart';
import 'package:banda/entity/category.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/loan_payment.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/pair.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

class LoanPaymentRepository extends Repository {
  WithArgs withArgs;

  LoanPaymentRepository(super.db, {WithArgs? withArgs})
    : withArgs = withArgs ?? {};

  LoanPaymentRepository withAccount() {
    withArgs.add("account");
    return this;
  }

  LoanPaymentRepository withEntry() {
    withArgs.add("entry");
    return this;
  }

  LoanPaymentRepository withLoan() {
    withArgs.add("loan");
    return this;
  }

  LoanPaymentRepository withCategory() {
    withArgs.add("category");
    return this;
  }

  static Future<LoanPaymentRepository> build() async {
    final db = await Repository.connect();
    return LoanPaymentRepository(db);
  }

  save(LoanPayment entity) async {
    db.execute(
      "INSERT INTO loan_payments (loan_id, entry_id, amount, fee, issued_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?) ON CONFLICT DO UPDATE SET amount = excluded.amount, fee = excluded.fee, entry_id = excluded.entry_id, loan_id = excluded.loan_id, issued_at = excluded.issued_at, updated_at = excluded.updated_at",
      [
        entity.loanId,
        entity.entryId,
        entity.amount,
        entity.fee,
        entity.issuedAt.toIso8601String(),
        entity.createdAt.toIso8601String(),
        entity.updatedAt.toIso8601String(),
      ],
    );
  }

  Future<List<LoanPayment>> search({Specification? specification}) async {
    var baseQuery = "SELECT loan_payments.* FROM loan_payments";

    final query = defineQuery(baseQuery, specification);
    final sqlString = "${query.first} ORDER BY loan_payments.created_at DESC";
    final sqlArgs = query.second;

    final loanRows = db.select(sqlString, sqlArgs);

    return await entities(loanRows);
  }

  Future<LoanPayment> get(String loanId, String entryId) async {
    final rows = db.select(
      "SELECT * FROM loan_payments WHERE loan_id = ? AND entry_id = ?",
      [loanId, entryId],
    );
    return entities(rows).then((entity) => entity.first);
  }

  delete(String loanId, String entryId) async {
    db.execute("DELETE FROM loan_payments WHERE loan_id = ? AND entry_id = ?", [
      loanId,
      entryId,
    ]);
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

  whereQuery(Specification? specification) {
    if (specification == null) return null;

    final Map<String, dynamic> where = {
      "args": <dynamic>[],
      "query": <String>[],
      "sql": null,
    };

    if (specification.containsKey("loan_in")) {
      final value = specification["loan_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loan_payments.loan_id IN (${value.map((_) => "?").join(", ")}))",
        );
        where["args"].addAll(value);
      }
    }

    if (specification.containsKey("entry_in")) {
      final value = specification["entry_in"] as List<String>;
      if (value.isNotEmpty) {
        where["query"].add(
          "(loan_payments.entry_id IN (${value.map((_) => "?").join(", ")}))",
        );
        where["args"].addAll(value);
      }
    }

    if (specification.containsKey("created_between")) {
      final value = specification["created_between"] as DateTimeRange;
      where["query"].add("(loan_payments.created_at BETWEEN ? AND ?)");
      where["args"].addAll([
        value.start.toIso8601String(),
        value.end.toIso8601String(),
      ]);
    }

    if (specification.containsKey("updated_between")) {
      final value = specification["updated_between"] as DateTimeRange;
      where["query"].add("(loan_payments.updated_at BETWEEN ? AND ?)");
      where["args"].addAll([
        value.start.toIso8601String(),
        value.end.toIso8601String(),
      ]);
    }

    if (specification.containsKey("issued_between")) {
      final value = specification["issued_between"] as DateTimeRange;
      where["query"].add("(loan_payments.issued_at BETWEEN ? AND ?)");
      where["args"].addAll([
        value.start.toIso8601String(),
        value.end.toIso8601String(),
      ]);
    }

    where["sql"] = where["query"].join(" AND ");
    return where;
  }

  Future<List<LoanPayment>> entities(List<Map> rows) async {
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

      if (withArgs.contains("category")) {
        final categoryIds = rows
            .map((row) => row["entry"]["category_id"] as String)
            .toList();
        final categoryRows = await getCategoryByIds(categoryIds);

        rows = rows.map((row) {
          return {
            ...row,
            "category": categoryRows.firstWhere(
              (categoryRow) => categoryRow["id"] == row["entry"]["category_id"],
            ),
          };
        }).toList();
      }

      if (withArgs.contains("account")) {
        final accountIds = rows
            .map((row) => row["entry"]["account_id"] as String)
            .toList();
        final accountRows = await getAccountByIds(accountIds);

        rows = rows.map((row) {
          return {
            ...row,
            "account": accountRows.firstWhere(
              (accountRow) => accountRow["id"] == row["entry"]["account_id"],
            ),
          };
        }).toList();
      }
    }

    if (withArgs.contains("loan")) {
      final loanIds = rows
          .map((row) => row["loan_id"] as String)
          .toList();
      final loanRows = await getLoanByIds(loanIds);

      rows = rows.map((row) {
        return {
          ...row,
          "loan": loanRows.firstWhere(
            (loanRow) => loanRow["id"] == row["loan_id"],
          ),
        };
      }).toList();
    }

    return rows.map((row) {
      final loan = Loan.tryParse(row["loan"]);
      final entry = Entry.tryRow(row["entry"])
          ?.withCategory(Category.tryRow(row["category"]))
          .withAccount(Account.tryRow(row["account"]));

      return LoanPayment.fromRow(row).withLoan(loan).withEntry(entry);
    }).toList();
  }
}
