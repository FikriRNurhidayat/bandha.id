import 'package:banda/features/tags/entities/party.dart';
import "package:banda/common/repositories/repository.dart";
import 'package:sqlite3/sqlite3.dart';

// TODO: Please ensure this looks like other repo
class PartyRepository extends Repository {
  PartyRepository._(super.db);

  static Future<PartyRepository> build() async {
    final db = await Repository.connect();
    return PartyRepository._(db);
  }

  Future<Party> create({required String name}) async {
    try {
      final id = Repository.getId();
      final now = DateTime.now();

      db.execute(
        "INSERT INTO parties (id, name, created_at, updated_at) VALUES (?, ?, ?, ?)",
        [id, name, now.toIso8601String(), now.toIso8601String()],
      );

      return Party(id: id, name: name, createdAt: now, updatedAt: now);
    } catch (error) {
      rethrow;
    }
  }

  Future<Party?> update({required String id, required String name}) async {
    final now = DateTime.now();

    db.execute("UPDATE parties SET name = ?, updated_at = ? WHERE id = ?", [
      name,
      now.toIso8601String(),
      id,
    ]);

    return get(id);
  }

  Future<Party> get(String id) async {
    final List<Map> rows = db.select("SELECT * FROM parties WHERE id = ?", [
      id,
    ]);

    return Party.row(rows.first);
  }

  Future<List<Party>> search() async {
    final ResultSet rows = db.select("SELECT * FROM parties ORDER BY name ASC");
    return rows.map((row) => Party.row(row)).toList();
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM parties WHERE id = ?", [id]);
  }
}
