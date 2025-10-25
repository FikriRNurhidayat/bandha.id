import 'package:banda/entity/itemable.dart';

class Party extends Itemable {
  @override
  final String id;
  @override
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  @override
  final readonly = false;

  Party({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Party.fromRow(Map<dynamic, dynamic> row) {
    return Party(
      id: row["id"],
      name: row["name"],
      createdAt: DateTime.parse(row["created_at"]),
      updatedAt: DateTime.parse(row["updated_at"]),
    );
  }
}
