abstract class Hydrator<T> {
  Future<T> hydrate(T entity);
  Future<Iterable<T>> hydrateAll(Iterable<T> entities);
}
