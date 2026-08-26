import 'package:bandha/core/data/data_sources/local_storage.dart';
import 'package:bandha/core/data/services/hydrator.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';

abstract class RepositoryImpl<T extends Entity> implements Repository<T> {
  abstract final LocalStorage<T> localStorage;

  @override
  Future<Iterable<T>> getAll(Iterable<String> ids) async {
    if (ids.isEmpty) return [];
    return localStorage.findAll({"id_in": ids});
  }

  @override
  Future<T> get(String id) async {
    final entity = await localStorage.find({"id_eq": id});
    if (entity == null) {
      throw Exception();
    }
    return entity;
  }

  @override
  Future<Iterable<T>> saveAll(Iterable<T> entities) async {
    await localStorage.saveAll(entities);
    return entities;
  }

  @override
  Future<T> save(T entity) async {
    await localStorage.save(entity);
    return entity;
  }

  @override
  Future<Iterable<T>> findAll(DataFilter filter) {
    return localStorage.findAll(filter);
  }

  @override
  Future<T?> find(DataFilter filter) {
    return localStorage.find(filter);
  }

  @override
  Future<void> destroyAll(Iterable<T> entities) {
    return localStorage.destroyAll(entities);
  }

  @override
  Future<void> destroy(T entity) {
    return localStorage.destroy(entity);
  }

  @override
  Future<DataList<T>> query(DataQuery query) {
    return localStorage.query(query);
  }
}

abstract class HydratedRepositoryImpl<T extends Entity>
    extends RepositoryImpl<T>
    implements Repository<T> {
  @override
  abstract final LocalStorage<T> localStorage;
  abstract final Hydrator<T> hydrator;

  @override
  Future<Iterable<T>> getAll(Iterable<String> ids) async {
    final entities = await super.getAll(ids);
    return hydrator.hydrateAll(entities);
  }

  @override
  Future<T> get(String id) async {
    final entity = await super.get(id);
    return hydrator.hydrate(entity);
  }

  @override
  Future<Iterable<T>> findAll(DataFilter filter) async {
    final entities = await super.findAll(filter);
    return hydrator.hydrateAll(entities);
  }

  @override
  Future<T?> find(DataFilter filter) async {
    final entity = await super.find(filter);
    if (entity == null) return null;
    return hydrator.hydrate(entity);
  }

  @override
  Future<DataList<T>> query(DataQuery query) async {
    final dataList = await localStorage.query(query);
    return dataList.copyWith(hits: await hydrator.hydrateAll(dataList.hits));
  }
}
