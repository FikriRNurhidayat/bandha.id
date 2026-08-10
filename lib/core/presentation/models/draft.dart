import 'package:bandha/core/domain/entity.dart';

class Draft<E extends Entity> {
  final E entity;
  bool isSaved = false;

  Draft(this.entity);
}
