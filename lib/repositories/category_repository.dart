import 'package:banda/entity/category.dart';
import "package:banda/repositories/repository.dart";
import 'package:sqlite3/sqlite3.dart';

// TODO: Please ensure this looks like other repo
class CategoryRepository extends Repository {
  CategoryRepository._(super.db);

  static Future<CategoryRepository> build() async {
    final db = await Repository.connect();
    return CategoryRepository._(db);
  }

  Future<List<Map>> dominant() async {
    final rows = db.select(
      """SELECT c.id, c.name, COUNT(e.id) AS entries_count, SUM(e.amount) AS entries_amount
  FROM categories c
  LEFT JOIN entries e ON e.category_id = c.id
  WHERE c.readonly IS FALSE
  GROUP BY c.id, c.name
  ORDER BY entries_amount ASC
  LIMIT 5;
      """,
    );

    if (rows.isEmpty) {
      return [];
    }

    return rows.toList();
  }

  Future<Category> create({required String name}) async {
    final id = Repository.getId();
    final now = DateTime.now();

    db.execute(
      "INSERT INTO categories (id, name, readonly, created_at, updated_at) VALUES (?, ?, ?, ?, ?)",
      [id, name, 0, now.toIso8601String(), now.toIso8601String()],
    );

    return Category(
      id: id,
      name: name,
      readonly: true,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }

  Future<Category?> update({required String id, required String name}) async {
    final now = DateTime.now();

    db.execute("UPDATE categories SET name = ?, updated_at = ? WHERE id = ?", [
      name,
      now.toIso8601String(),
      id,
    ]);

    return get(id);
  }

  Future<Category> getByName(String name) async {
    final ResultSet rows = db.select(
      "SELECT * FROM categories WHERE name = ?",
      [name],
    );

    return Category.row(rows.first);
  }

  Future<Category> get(String id) async {
    final ResultSet rows = db.select("SELECT * FROM categories WHERE id = ?", [
      id,
    ]);

    return Category.row(rows.first);
  }

  Future<List<Category>> search() async {
    final ResultSet rows = db.select(
      "SELECT * FROM categories ORDER BY name ASC",
    );
    return rows.map((row) => Category.row(row)).toList();
  }

  Future<void> delete(String id) async {
    db.execute("DELETE FROM categories WHERE id = ?", [1]);
  }
}
