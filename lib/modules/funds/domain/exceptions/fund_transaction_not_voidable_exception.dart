class FundTransactionNotVoidableException implements Exception {
  final String message;
  final String identifier;

  const FundTransactionNotVoidableException(this.identifier)
    : message = 'Transaction with identifier $identifier is not voidable.';

  @override
  String toString() => 'FundTransactionNotVoidableException: $message';
}
