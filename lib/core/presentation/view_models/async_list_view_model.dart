import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/types/pager.dart';
import 'package:bandha/core/presentation/view_models/async_view_model.dart';
import 'package:flutter/widgets.dart';

class AsyncListViewModel<E extends Entity>
    extends AsyncViewModel<Pager<Item<E>>> {
  final ValueNotifier<DataFilter?> filterNotifier = ValueNotifier({});
  final QueryEntities<E> queryEntities;
  final DestroyEntity<E> destroyEntity;

  AsyncListViewModel._({
    required this.queryEntities,
    required this.destroyEntity,
  });

  factory AsyncListViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<AsyncListViewModel<E>>();
  }

  factory AsyncListViewModel.build(DependencyContainer c) {
    return AsyncListViewModel<E>._(
      queryEntities: c.get<QueryEntities<E>>(),
      destroyEntity: c.get<DestroyEntity<E>>(),
    );
  }

  DataFilter? get filter => filterNotifier.value;

  Future<Pager<Item<E>>> init() async {
    final query = await queryEntities.execute(filter: filter);
    final models = query.hits.map((entity) => Item<E>(entity)).toList();
    final pager = Pager<Item<E>>.of(models);
    return pager.withPreviousCursor(query.previous).withNextCursor(query.next);
  }

  Pager<Item<E>> get pager => notifier.value.requireData;

  Future<void> query() => execute((_) => init());

  Future<void> next() => execute((pager) async {
    if (pager == null) return init();

    final query = await queryEntities.execute(filter: filter);
    final models = query.hits.map((entity) => Item<E>(entity)).toList();

    return pager
        .withNext(models)
        .withPreviousCursor(query.previous)
        .withNextCursor(query.next);
  });

  Future<void> previous() => execute((pager) async {
    if (pager == null) return init();

    final query = await queryEntities.execute(filter: filter);
    final models = query.hits.map((entity) => Item<E>(entity)).toList();

    return pager
        .withPrevious(models)
        .withPreviousCursor(query.previous)
        .withNextCursor(query.next);
  });

  Future<void> destroy(Item<E> i) async {
    await execute((pager) async {
      await destroyEntity.execute(i.entity.id);
      return init();
    });
  }
}
