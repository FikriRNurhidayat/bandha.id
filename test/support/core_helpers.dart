import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/data/data_sources/local_storage.dart';
import 'package:bandha/core/data/services/hydrator.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/events/domain_event.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';

/// Minimal entity for core tests.
class Thing extends Controllable {
  @override
  final String id;
  final String name;
  final bool hydrated;

  Thing(this.id, {this.name = "thing", this.hydrated = false});

  Thing hydrate() => Thing(id, name: name, hydrated: true);
}

class OtherThing extends Entity {
  @override
  final String id;
  OtherThing(this.id);
}

/// Records every call and returns canned results.
class FakeLocalStorage<T> implements LocalStorage<T> {
  final List<String> calls = [];
  final List<DataFilter> filters = [];
  final List<DataQuery> queries = [];
  final List<Object?> args = [];

  T? findResult;
  Iterable<T> findAllResult = const [];
  DataList<T>? queryResult;

  @override
  Future<void> destroy(T entity) async {
    calls.add("destroy");
    args.add(entity);
  }

  @override
  Future<void> destroyAll(Iterable<T> entities) async {
    calls.add("destroyAll");
    args.add(entities);
  }

  @override
  Future<void> save(T entity) async {
    calls.add("save");
    args.add(entity);
  }

  @override
  Future<void> saveAll(Iterable<T> entities) async {
    calls.add("saveAll");
    args.add(entities);
  }

  @override
  Future<T?> find(DataFilter filter) async {
    calls.add("find");
    filters.add(filter);
    return findResult;
  }

  @override
  Future<Iterable<T>> findAll(DataFilter filter) async {
    calls.add("findAll");
    filters.add(filter);
    return findAllResult;
  }

  @override
  Future<DataList<T>> query(DataQuery query) async {
    calls.add("query");
    queries.add(query);
    return queryResult ??
        DataList<T>(hasNext: false, hasPrevious: false, hits: const []);
  }
}

class ThingHydrator implements Hydrator<Thing> {
  int hydrateCalls = 0;
  int hydrateAllCalls = 0;

  @override
  Future<Thing> hydrate(Thing entity) async {
    hydrateCalls++;
    return entity.hydrate();
  }

  @override
  Future<Iterable<Thing>> hydrateAll(Iterable<Thing> entities) async {
    hydrateAllCalls++;
    return entities.map((e) => e.hydrate()).toList();
  }
}

class PingEvent extends DomainEvent {
  final int n;
  PingEvent(this.n);
}

class PongEvent extends DomainEvent {
  final int n;
  PongEvent(this.n);
}

/// Records each call to [handle] and [handleAll] separately.
class RecordingHandler<E extends DomainEvent> extends EventHandler<E> {
  final List<E> handled = [];
  final List<List<E>> batches = [];
  int handleCalls = 0;
  Future<void> Function(E event)? onHandle;

  RecordingHandler({this.onHandle});

  @override
  Future<void> handle(E event) async {
    handleCalls++;
    handled.add(event);
    await onHandle?.call(event);
  }

  @override
  Future<void> handleAll(Iterable<E> events) async {
    batches.add(events.toList());
    await super.handleAll(events);
  }
}
