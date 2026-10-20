import 'package:bandha/modules/assets/domain/exceptions/missing_asset_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("MissingAssetException", () {
    test("carries identifier and message", () {
      const e = MissingAssetException("IDR");

      expect(e.identifier, "IDR");
      expect(e.message, "Asset with identifier IDR is missing.");
      expect(
        e.toString(),
        "MissingAssetException: Asset with identifier IDR is missing.",
      );
      expect(e, isA<Exception>());
    });
  });
}
