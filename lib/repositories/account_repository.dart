import "package:banda/entity/account.dart";
import "package:banda/repositories/repository.dart";
import "package:sqlite3/sqlite3.dart";

class AccountRepository extends Repository {
  AccountRepository._(super.db);

  static Future<AccountRepository> build() async {
    final db = await Repository.connect();
    return AccountRepository._(db);
  }

  Future<Account> create({
    required String name,
    required String holderName,
    required AccountKind kind,
  }) async {
    final id = Repository.getId();
    final now = DateTime.now();

    db.execute(
      "INSERT INTO accounts (id, name, holder_name, kind, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)",
      [
        id,
        name,
        holderName,
        kind.label,
        now.toIso8601String(),
        now.toIso8601String(),
      ],
    );

    return Account(
      id: id,
      name: name,
      holderName: holderName,
      kind: kind,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<Account?> update({
    required String id,
    required String name,
    required String holderName,
    required AccountKind kind,
  }) async {
    final now = DateTime.now();

    db.execute(
      "UPDATE accounts SET name = ?, holder_name = ?, kind = ?, updated_at = ? WHERE id = ?",
      [name, holderName, kind.label, now.toIso8601String(), id],
    );

    return get(id);
  }

  Future<Account?> get(String id) async {
    final ResultSet result = db.select("SELECT * FROM accounts WHERE id = ?", [
      id,
    ]);

    if (result.isEmpty) {
      return null;
    }

    return Account.fromRow(result.first);
  }

  Future<List<Account>> withBalances() async {
    final ResultSet rows = db.select("""
      SELECT accounts.*, SUM(entries.amount) AS balance
      FROM accounts
      LEFT JOIN entries ON entries.account_id = accounts.id AND entries.status = 'Done'
      GROUP BY accounts.id
      ORDER BY balance DESC
    """);
    return rows.map((row) => Account.fromRow(row)).toList();
  }

  Future<List<Account>> search() async {
    try {
      final ResultSet rows = db.select(
        "SELECT * FROM accounts ORDER BY accounts.name, accounts.holder_name;",
      );
      return rows.map((row) => Account.fromRow(row)).toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM accounts WHERE id = ?", [id]);
  }
}
