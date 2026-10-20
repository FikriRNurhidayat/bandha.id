import 'package:bandha/core/types/pair.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Pair holds both values", () {
    const p = Pair("a", 1);
    expect(p.first, "a");
    expect(p.second, 1);
  });
}
