enum TransactionType {
  deposit('Deposit'),
  withdrawal('Withdrawal');

  final String label;
  const TransactionType(this.label);
}
