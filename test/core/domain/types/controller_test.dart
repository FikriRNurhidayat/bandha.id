import 'package:bandha/core/domain/types/controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Controller", () {
    test("fromRow reads controller columns", () {
      final c = Controller.fromRow({
        "controller_id": "x",
        "controller_type": "Fund",
      });
      expect(c.id, "x");
      expect(c.type, "Fund");
    });

    test("tryRow returns null without controller_id", () {
      expect(Controller.tryRow({}), isNull);
      expect(
        Controller.tryRow({"controller_id": null, "controller_type": "Fund"}),
        isNull,
      );
    });

    test("tryRow parses when controller_id is present", () {
      final c = Controller.tryRow({
        "controller_id": "x",
        "controller_type": "Fund",
      });
      expect(c?.id, "x");
      expect(c?.type, "Fund");
    });

    test("toJson", () {
      expect(Controller(id: "x", type: "Fund").toJson(), {
        "id": "x",
        "type": "Fund",
      });
    });
  });
}
