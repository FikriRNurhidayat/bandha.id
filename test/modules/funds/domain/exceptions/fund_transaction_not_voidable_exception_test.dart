import 'package:bandha/modules/funds/domain/exceptions/fund_transaction_not_voidable_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("FundTransactionNotVoidableException", () {
    test("carries identifier and message", () {
      const e = FundTransactionNotVoidableException("e1");

      expect(e, isA<Exception>());
      expect(e.identifier, "e1");
      expect(e.message, "Transaction with identifier e1 is not voidable.");
      expect(
        e.toString(),
        "FundTransactionNotVoidableException: "
        "Transaction with identifier e1 is not voidable.",
      );
    });
  });
}
