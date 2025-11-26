enum ControllerType {
  savings('Savings'),
  transfer('Transfer'),
  loan('Loan'),
  bill('Bill');

  final String label;
  const ControllerType(this.label);
}
