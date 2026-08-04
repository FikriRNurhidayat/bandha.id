import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/controller.dart';

abstract class Controllable extends Entity {
  Controller toController() {
    return Controller(id: id, type: runtimeType.toString());
  }

  Controller get controller {
    return Controller(id: id, type: runtimeType.toString());
  }
}
