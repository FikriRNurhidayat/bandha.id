import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/core/domain/types/data_filter.dart';

abstract class Controllable extends Entity {
  Controller toController() {
    return Controller(id: id, type: runtimeType.toString());
  }

  Controller get controller {
    return Controller(id: id, type: runtimeType.toString());
  }

  DataFilter get dataFilter {
    return {
      "controller_id_eq": controller.id,
      "controller_type_eq": controller.type,
    };
  }
}
