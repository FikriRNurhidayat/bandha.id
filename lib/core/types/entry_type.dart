enum EntryType {
  income('Income'),
  expense('Expense');

  bool isIncome() {
    return this == EntryType.income;
  }

  bool isExpense() {
    return this == EntryType.expense;
  }

  @override
  toString() {
    return label;
  }

  final String label;
  const EntryType(this.label);
}
