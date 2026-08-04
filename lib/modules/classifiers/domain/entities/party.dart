import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';

class Party extends Classifier<Party> {
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

  Party({
    required this.id,
    required this.name,
    required this.readOnly,
    required this.createdAt,
    required this.updatedAt,
  });

  static Party? tryRow(Map? row) {
    if (row == null) return null;
    return Party.fromRow(row);
  }

  factory Party.fromRow(Map row) {
    return Party(
      id: row["id"],
      name: row["name"],
      readOnly: false,
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }

  factory Party.create({required String name}) {
    final now = DateTime.now();

    return Party(
      id: Entity.getId(),
      name: name,
      readOnly: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Party copyWith({required String name}) {
    throw UnimplementedError();
  }
}
