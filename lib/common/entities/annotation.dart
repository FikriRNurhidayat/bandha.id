import 'dart:convert';

import 'package:banda/common/entities/entity.dart';

enum Annotations { type, quantity, subtotal }

enum AnnotationType {
  fee;

  @override
  toString() {
    return fee.name;
  }
}

class Annotation extends Entity {
  final String entryId;
  final Annotations name;
  final dynamic value;

  Annotation({required this.entryId, required this.name, required this.value});

  static Annotation? tryRow(Map<String, dynamic>? row) {
    if (row == null) return null;
    return Annotation.row(row);
  }

  factory Annotation.row(Map<String, dynamic> row) {
    return Annotation(
      entryId: row["entry_id"],
      name: row["name"],
      value: jsonDecode(row["value"]),
    );
  }
}
