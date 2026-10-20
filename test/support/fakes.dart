import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:bandha/core/domain/unit_of_work.dart';

/// Runs the block directly and counts how many times it was used.
class FakeUnitOfWork implements UnitOfWork {
  int executions = 0;

  @override
  Future<R> execute<R>(Future<R> Function() block) {
    executions++;
    return block();
  }
}

/// Records raised events without dispatching them.
class RecordingEventPublisher implements DomainEventPublisher {
  final List<DomainEvent> raised = [];
  final List<EventHandler> registered = [];
  int dispatches = 0;

  Iterable<E> ofType<E extends DomainEvent>() => raised.whereType<E>();

  @override
  Future<void> raise(DomainEvent event) async => raised.add(event);

  @override
  Future<void> raiseAll(Iterable<DomainEvent> events) async =>
      raised.addAll(events);

  @override
  Future<void> dispatch() async => dispatches++;

  @override
  void clear() => raised.clear();

  @override
  void register<E extends DomainEvent>(EventHandler<E> handler) =>
      registered.add(handler);
}

/// A map-backed repository. Supports `id_eq` and `id_in` filters; any other
/// key is matched against [fieldsOf] when provided.
class InMemoryRepository<T extends Entity> implements Repository<T> {
  final Map<String, T> store = {};
  final List<T> saved = [];
  final List<T> destroyed = [];
  final Map<String, dynamic> Function(T entity)? fieldsOf;

  InMemoryRepository({Iterable<T> seed = const [], this.fieldsOf}) {
    for (final entity in seed) {
      store[entity.id] = entity;
    }
  }

  bool matches(T entity, DataFilter filter) {
    for (final MapEntry(:key, :value) in filter.entries) {
      if (key == "id_eq") {
        if (entity.id != value) return false;
      } else if (key == "id_in") {
        if (!(value as Iterable).contains(entity.id)) return false;
      } else if (fieldsOf != null) {
        final fields = fieldsOf!(entity);
        if (key.endsWith("_eq")) {
          if (fields[key.substring(0, key.length - 3)] != value) return false;
        } else if (key.endsWith("_in")) {
          final field = fields[key.substring(0, key.length - 3)];
          if (!(value as Iterable).contains(field)) return false;
        }
      }
    }
    return true;
  }

  @override
  Future<T> get(String id) async {
    final entity = store[id];
    if (entity == null) throw Exception("$T $id not found");
    return entity;
  }

  @override
  Future<Iterable<T>> getAll(Iterable<String> ids) async =>
      ids.where(store.containsKey).map((id) => store[id]!).toList();

  @override
  Future<T> save(T entity) async {
    store[entity.id] = entity;
    saved.add(entity);
    return entity;
  }

  @override
  Future<Iterable<T>> saveAll(Iterable<T> entities) async {
    for (final entity in entities) {
      await save(entity);
    }
    return entities;
  }

  @override
  Future<T?> find(DataFilter filter) async {
    for (final entity in store.values) {
      if (matches(entity, filter)) return entity;
    }
    return null;
  }

  @override
  Future<Iterable<T>> findAll(DataFilter filter) async =>
      store.values.where((e) => matches(e, filter)).toList();

  @override
  Future<void> destroy(T entity) async {
    store.remove(entity.id);
    destroyed.add(entity);
  }

  @override
  Future<void> destroyAll(Iterable<T> entities) async {
    for (final entity in entities.toList()) {
      await destroy(entity);
    }
  }

  DataQuery? lastQuery;

  @override
  Future<DataList<T>> query(DataQuery query) async {
    lastQuery = query;
    final hits = store.values
        .where((e) => matches(e, query.filter))
        .take(query.size)
        .toList();
    return DataList<T>(hasNext: false, hasPrevious: false, hits: hits);
  }
}
