abstract class DomainReader<T> {
  Future<T> get(String id);
  Future<Iterable<T>> getAll(Iterable<String> ids);
}
