import 'package:uuid/uuid.dart';

abstract class Entity {
  String get id;

  static String getId() {
    return Uuid().v7();
  }
}
