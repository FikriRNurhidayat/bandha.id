import 'package:bandha/core/types/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("TransactionType", () {
    test("deposit predicates", () {
      expect(TransactionType.deposit.isDeposit, isTrue);
      expect(TransactionType.deposit.isWithdraw, isFalse);
    });

    test("withdraw predicates", () {
      expect(TransactionType.withdraw.isWithdraw, isTrue);
      expect(TransactionType.withdraw.isDeposit, isFalse);
    });

    test("no value is a disbursement", () {
      for (final t in TransactionType.values) {
        expect(t.isDisbursement, isFalse);
      }
    });

    test("toString returns the label", () {
      expect(TransactionType.deposit.toString(), "Deposit");
      expect(TransactionType.withdraw.toString(), "Withdraw");
    });
  });
}
