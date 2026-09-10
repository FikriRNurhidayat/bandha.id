class InvalidDatabaseException implements Exception {
  final String message;

  const InvalidDatabaseException() : message = 'Database is not valid.';

  @override
  String toString() => 'MissingAssetException: $message';
}
