import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';

class Category extends Classifier<Category> {
  @override
  final String id;

  @override
  final String name;

  @override
  final bool readOnly;

  @override
  final DateTime createdAt;

  @override
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.readOnly,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.create({required String name}) {
    final now = DateTime.now();

    return Category(
      id: Entity.getId(),
      name: name,
      readOnly: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Category.fromRow(Map row) {
    return Category(
      id: row["id"],
      name: row["name"],
      readOnly: row["readonly"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }

  static Category? tryRow(Map? row) {
    if (row == null) return null;
    return Category.fromRow(row);
  }

  @override
  Category copyWith({required String name}) {
    // TODO: implement copyWith
    throw UnimplementedError();
  }
}
