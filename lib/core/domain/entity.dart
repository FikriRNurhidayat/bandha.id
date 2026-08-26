import 'package:uuid/uuid.dart';

abstract class Entity {
  String get id;

  @override
  bool operator ==(Object other) =>
      other is Entity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static String getId() {
    return Uuid().v7();
  }
}
