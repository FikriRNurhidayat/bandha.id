import 'package:banda/entity/entity.dart';
import 'package:banda/types/controller.dart';

abstract class Controlable extends Entity {
  Controller toController();
}
