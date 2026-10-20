import 'package:bandha/core/types/confirm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Confirm", () {
    test("value maps yes to true and no to false", () {
      expect(Confirm.yes.value, isTrue);
      expect(Confirm.no.value, isFalse);
    });

    test("labels", () {
      expect(Confirm.yes.label, "Yes");
      expect(Confirm.no.label, "No");
    });
  });
}
