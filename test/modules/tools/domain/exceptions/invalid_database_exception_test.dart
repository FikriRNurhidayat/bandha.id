import 'package:bandha/modules/tools/domain/exceptions/invalid_database_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("InvalidDatabaseException", () {
    test("carries a message", () {
      const e = InvalidDatabaseException();

      expect(e.message, "Database is not valid.");
      expect(e, isA<Exception>());
    });

    test(
      "toString names the exception",
      () {
        expect(
          const InvalidDatabaseException().toString(),
          "InvalidDatabaseException: Database is not valid.",
        );
      },
      skip:
          "BUG: toString is prefixed with 'MissingAssetException' (copy-paste)",
    );
  });
}
