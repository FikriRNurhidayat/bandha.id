class MissingAssetException implements Exception {
  final String message;
  final String identifier;

  const MissingAssetException(this.identifier)
    : message = 'Asset with identifier $identifier is missing.';

  @override
  String toString() => 'MissingAssetException: $message';
}
