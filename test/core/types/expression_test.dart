import 'package:bandha/core/types/expression.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Expression", () {
    test("holds a leaf comparison", () {
      final e = Expression(operator: Operator.equals, field: "name", value: 1);
      expect(e.operator.value, "eq");
      expect(e.field, "name");
      expect(e.value, 1);
      expect(e.rules, isNull);
    });

    test("nests rules", () {
      final leaf = Expression(operator: Operator.greaterThan, field: "a");
      final e = Expression(operator: Operator.and, rules: [leaf]);
      expect(e.rules, [leaf]);
    });

    test("operator codes", () {
      expect(Operator.values.map((o) => o.value), [
        "ne",
        "eq",
        "gt",
        "gte",
        "lt",
        "lte",
        "and",
        "or",
        "not",
      ]);
    });
  });
}
