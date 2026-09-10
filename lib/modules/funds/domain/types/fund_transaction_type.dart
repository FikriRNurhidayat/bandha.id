enum FundTransactionType {
  deposit('Deposit'),
  withdraw('Withdraw'),
  disbursement('Disbursement');

  final String label;
  const FundTransactionType(this.label);

  @override
  toString() {
    return label;
  }

  bool get isDeposit {
    return this == FundTransactionType.deposit;
  }

  bool get isWithdraw {
    return this == FundTransactionType.withdraw;
  }

  bool get isDisbursement {
    return this == FundTransactionType.disbursement;
  }
}
