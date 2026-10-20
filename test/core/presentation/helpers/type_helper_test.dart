import 'package:bandha/core/presentation/helpers/type_helper.dart' as type;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("isNull", () {
    expect(type.isNull(null), isTrue);
    expect(type.isNull(0), isFalse);
    expect(type.isNull(""), isFalse);
  });

  test("isZero", () {
    expect(type.isZero(null), isTrue);
    expect(type.isZero(0), isTrue);
    expect(type.isZero(0.0), isTrue);
    expect(type.isZero(1), isFalse);
  });

  test("isEmpty", () {
    expect(type.isEmpty(null), isTrue);
    expect(type.isEmpty([]), isTrue);
    expect(type.isEmpty([1]), isFalse);
  });
}
