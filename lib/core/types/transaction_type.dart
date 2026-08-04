enum TransactionType {
  deposit('Deposit'),
  withdraw('Withdraw');

  final String label;
  const TransactionType(this.label);

  bool get isDeposit {
    return this == TransactionType.deposit;
  }

  bool get isWithdraw {
    return this == TransactionType.withdraw;
  }

  bool get isDisbursement {
    return false;
  }
}
