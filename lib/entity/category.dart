import 'package:banda/entity/itemable.dart';

class Category extends Itemable {
  @override
  final String id;
  @override
  final String name;
  @override
  final bool readonly;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Category({
    required this.id,
    required this.name,
    required this.readonly,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  static tryRow(Map? row) {
    if (row == null) return null;
    return Category.row(row);
  }

  factory Category.row(Map<dynamic, dynamic> row) {
    return Category(
      id: row["id"],
      name: row["name"],
      readonly: row["readonly"] == 1,
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
      deletedAt: row["deleted_at"],
    );
  }
}
