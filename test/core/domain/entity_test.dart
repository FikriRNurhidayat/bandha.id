import 'package:bandha/core/domain/entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/core_helpers.dart';

void main() {
  group("Entity", () {
    test("equal when same type and id", () {
      expect(Thing("a", name: "x"), Thing("a", name: "y"));
      expect(Thing("a").hashCode, Thing("a").hashCode);
    });

    test("not equal with different id", () {
      expect(Thing("a"), isNot(Thing("b")));
    });

    test("not equal across types with same id", () {
      final Entity a = Thing("a");
      final Entity b = OtherThing("a");
      expect(a == b, isFalse);
      expect(b == a, isFalse);
    });

    test("not equal to non-entities", () {
      // ignore: unrelated_type_equality_checks
      expect(Thing("a") == "a", isFalse);
    });

    test("deduplicates in sets by id", () {
      expect({Thing("a"), Thing("a"), Thing("b")}, hasLength(2));
    });

    test("getId returns unique uuid v7 strings", () {
      final ids = List.generate(100, (_) => Entity.getId());
      expect(ids.toSet(), hasLength(100));
      for (final id in ids) {
        expect(
          id,
          matches(
            RegExp(
              r"^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$",
            ),
          ),
        );
      }
    });
  });
}
