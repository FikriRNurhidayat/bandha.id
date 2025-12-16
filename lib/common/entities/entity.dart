import 'package:uuid/uuid.dart';

abstract class Entity {
  static String getId() {
    return Uuid().v4();
  }
}
