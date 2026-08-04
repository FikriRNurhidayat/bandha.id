import 'package:bandha/core/domain/entity.dart';

abstract class Classifier<T> extends Entity {
  String get name;
  bool get readOnly;
  DateTime get createdAt;
  DateTime get updatedAt;

  T copyWith({required String name});
}
