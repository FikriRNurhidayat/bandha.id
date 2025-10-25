import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/repositories/repository.dart';

class LoanRepository extends Repository {
  LoanRepository._(super.db);

  static Future<LoanRepository> build() async {
    final db = await Repository.connect();
    return LoanRepository._(db);
  }

  Future<List<Loan>> search() async {
    final rows = db.select("SELECT * FROM loans");
    return rows.map((row) => Loan.fromRow(row)).toList();
  }

  Future<Loan?> get(String id) async {
    final rows = db.select("SELECT * FROM loans WHERE id = ?", [id]);
    return rows.map((row) => Loan.fromRow(row)).toList().first;
  }

  Future<Loan> create({
    required double amount,
    required DateTime timestamp,
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
      final entries = await _makeEntries(
        kind: kind,
        status: status,
        accountId: accountId,
        partyId: partyId,
        settledAt: settledAt,
        timestamp: timestamp,
        now: now,
        amount: amount,
      );

      final debit = entries["debit"];
      final credit = entries["credit"];

      await insertEntry(debit);
      await insertEntry(credit);

      db.execute(
        "INSERT INTO loans (id, amount, fee, status, kind, timestamp, account_id, party_id, debit_id, credit_id, created_at, updated_at, settled_at, deleted_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        [
          id,
          amount,
          fee,
          status.label,
          kind.label,
          timestamp.toIso8601String(),
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
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  Future<Loan> update({
    required String id,
    required double amount,
    required DateTime timestamp,
    required DateTime settledAt,
    required LoanKind kind,
    required LoanStatus status,
    required String partyId,
    required String accountId,
    double? fee,
  }) async {
    throw UnimplementedError();
  }

  Future<void> remove(String id) async {
    return transaction<void>(() async {
      final loans = db.select("SELECT * FROM loans WHERE id = ?", [id]);
      if (loans.isEmpty) {
        return;
      }

      db.execute("DELETE FROM loans WHERE id = ?", [id]);
      db.execute("DELETE FROM entries WHERE id IN (?, ?)", [
        loans.first["debit_id"],
        loans.first["credit_id"],
      ]);
    });
  }

  Future<Map> _makeEntries({
    required LoanKind kind,
    required LoanStatus status,
    required String accountId,
    required String partyId,
    required DateTime timestamp,
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
          ? timestamp.toIso8601String()
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
          ? timestamp.toIso8601String()
          : settledAt.toIso8601String(),
      "category_id": category["id"],
      "account_id": account["id"],
      "created_at": now.toIso8601String(),
      "updated_at": now.toIso8601String(),
    };

    return {"debit": debit, "credit": credit};
  }
}
