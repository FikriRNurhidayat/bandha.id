import 'package:bandha/core/types/entry_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("EntryType", () {
    test("income predicates", () {
      expect(EntryType.income.isIncome(), isTrue);
      expect(EntryType.income.isExpense(), isFalse);
    });

    test("expense predicates", () {
      expect(EntryType.expense.isExpense(), isTrue);
      expect(EntryType.expense.isIncome(), isFalse);
    });

    test("toString returns the label", () {
      expect(EntryType.income.toString(), "Income");
      expect("${EntryType.expense}", "Expense");
    });
  });
}
