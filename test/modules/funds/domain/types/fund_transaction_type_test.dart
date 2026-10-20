import 'package:bandha/modules/funds/domain/types/fund_transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("FundTransactionType", () {
    test("toString returns label", () {
      expect(FundTransactionType.deposit.toString(), "Deposit");
      expect(FundTransactionType.withdraw.toString(), "Withdraw");
      expect(FundTransactionType.disbursement.toString(), "Disbursement");
    });

    test("predicates match exactly one value", () {
      for (final type in FundTransactionType.values) {
        expect(type.isDeposit, type == FundTransactionType.deposit);
        expect(type.isWithdraw, type == FundTransactionType.withdraw);
        expect(type.isDisbursement, type == FundTransactionType.disbursement);
      }
    });
  });
}
