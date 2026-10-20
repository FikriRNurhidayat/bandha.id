import 'package:bandha/core/types/maybe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Maybe", () {
    test("none is not specified and throws on value", () {
      expect(Maybe.none.isNone, isTrue);
      expect(Maybe.none.isSpecified, isFalse);
      expect(() => Maybe.none.value, throwsStateError);
    });

    test("wraps a provided value", () {
      const m = Maybe<int>(3);
      expect(m.isSpecified, isTrue);
      expect(m.isNone, isFalse);
      expect(m.value, 3);
    });

    test("distinguishes an explicit null from none", () {
      const m = Maybe<String>(null);
      expect(m.isSpecified, isTrue);
      expect(m.value, isNull);
    });
  });
}
