import 'package:bandha/core/domain/ports/domain_reader.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';

abstract class Repository<T> extends DomainReader<T> {
  Future<T> save(T entity);
  Future<Iterable<T>> saveAll(Iterable<T> entities);
  Future<T?> find(DataFilter filter);
  Future<Iterable<T>> findAll(DataFilter filter);
  Future<void> destroy(T entity);
  Future<void> destroyAll(Iterable<T> entities);
  Future<DataList<T>> query(DataQuery query);
}
