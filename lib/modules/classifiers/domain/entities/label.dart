import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';

class Label extends Classifier<Label> {
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

  Label({
    required this.id,
    required this.name,
    required this.readOnly,
    required this.createdAt,
    required this.updatedAt,
  });

  static Label? tryRow(Map? row) {
    if (row == null) return null;
    return Label.fromRow(row);
  }

  factory Label.fromRow(Map row) {
    return Label(
      id: row["id"],
      name: row["name"],
      readOnly: row["readonly"] == 1,
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }

  factory Label.create({required String name}) {
    final now = DateTime.now();

    return Label(
      id: Entity.getId(),
      name: name,
      readOnly: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Label copyWith({required String name}) {
    throw UnimplementedError();
  }
}
