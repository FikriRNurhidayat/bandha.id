import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';

abstract class LocalStorage<T> {
  Future<void> destroy(T entity);
  Future<void> destroyAll(Iterable<T> entities);
  Future<void> save(T entity);
  Future<void> saveAll(Iterable<T> entities);
  Future<T?> find(DataFilter filter);
  Future<Iterable<T>> findAll(DataFilter filter);
  Future<DataList<T>> query(DataQuery query);
}
