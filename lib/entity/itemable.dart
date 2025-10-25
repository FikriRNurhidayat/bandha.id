import 'dart:ffi';

abstract class Itemable {
  String get id;
  String get name;
  bool? get readonly;
}
