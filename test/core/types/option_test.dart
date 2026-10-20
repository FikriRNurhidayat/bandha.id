import 'package:bandha/core/types/option.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Option", () {
    test("Some carries a value", () {
      const Option<int> o = Some(4);
      expect(switch (o) {
        Some(:final value) => value,
        None() => -1,
      }, 4);
    });

    test("None has no value", () {
      const Option<int> o = None();
      expect(o, isA<None<int>>());
    });

    test("top-level none is a None", () {
      expect(none, isA<None>());
    });
  });
}
