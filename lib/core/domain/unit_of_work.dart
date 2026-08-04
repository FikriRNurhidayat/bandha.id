abstract class UnitOfWork {
  Future<R> execute<R>(Future<R> Function() block);
}
