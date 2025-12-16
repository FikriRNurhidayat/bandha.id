import 'package:banda/common/entities/entity.dart';
import 'package:banda/types/controller.dart';

abstract class Controlable extends Entity {
  Controller toController();
}
