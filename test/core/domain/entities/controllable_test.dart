import 'package:flutter_test/flutter_test.dart';

import '../../../support/core_helpers.dart';

void main() {
  group("Controllable", () {
    final thing = Thing("t1");

    test("toController uses id and runtime type", () {
      final c = thing.toController();
      expect(c.id, "t1");
      expect(c.type, "Thing");
    });

    test("controller getter matches toController", () {
      expect(thing.controller.toJson(), thing.toController().toJson());
    });

    test("dataFilter targets the controller", () {
      expect(thing.dataFilter, {
        "controller_id_eq": "t1",
        "controller_type_eq": "Thing",
      });
    });
  });
}
