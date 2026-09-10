import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/get_entity.dart';
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
  final ValueNotifier<bool> selectNotifier = ValueNotifier(false);
  final ValueNotifier<Set<Item<E>>> candidatesNotifier = ValueNotifier({});

  final GetEntity<E> getEntity;
  final QueryEntities<E> queryEntities;
  final DestroyEntity<E> destroyEntity;

  AsyncListViewModel({
    required this.queryEntities,
    required this.destroyEntity,
    required this.getEntity,
  });

  factory AsyncListViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<AsyncListViewModel<E>>();
  }

  factory AsyncListViewModel.build(DependencyContainer c) {
    return AsyncListViewModel<E>(
      queryEntities: c.get<QueryEntities<E>>(),
      destroyEntity: c.get<DestroyEntity<E>>(),
      getEntity: c.get<GetEntity<E>>(),
    );
  }

  DataFilter? get filter => filterNotifier.value;
  Set<Item<E>> get candidates => candidatesNotifier.value;
  bool get hasCandidates => candidates.isNotEmpty;

  void resetFilter() {
    filterNotifier.value = null;
  }

  void setFilter(DataFilter filter) {
    filterNotifier.value = filter;
  }

  Future<Pager<Item<E>>> init() async {
    final query = await queryEntities.execute(filter: filter);
    final models = query.hits.map((entity) {
      final item = itemBuilder(entity);
      item.isSelected = candidates.contains(item);
      return item;
    }).toList();
    final pager = Pager<Item<E>>.of(models);
    return pager.withPreviousCursor(query.previous).withNextCursor(query.next);
  }

  Pager<Item<E>> get pager => notifier.value.requireData;

  Future<void> query() => execute((_) => init());

  Future<void> removeItems(Iterable<Item<E>> items) async {
    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.where((i) => !items.contains(i)),
    );
  }

  Future<void> removeItem(Item<E> item) async {
    removeItems([item]);
  }

  Future<void> refreshItem(Item<E> item) async {
    final entity = await getEntity.execute(item.entity.id);

    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.map((i) {
        if (i.entity.id == item.entity.id) {
          return Item<E>(entity);
        }

        return i;
      }),
    );
  }

  Future<void> updateItem(Item<E> item) async {
    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.map((i) {
        if (i.entity.id == item.entity.id) {
          return item;
        }

        return i;
      }),
    );
  }

  Future<void> next() => execute((pager) async {
    if (pager == null) return init();

    final query = await queryEntities.execute(filter: filter);
    final models = query.hits.map((entity) => itemBuilder(entity)).toList();

    return pager
        .withNext(models)
        .withPreviousCursor(query.previous)
        .withNextCursor(query.next);
  });

  Future<void> deselect(Item<E> item) async {
    return deselectAll([item]);
  }

  Future<void> deselectAll(Iterable<Item<E>> items) async {
    candidatesNotifier.value.removeAll(items);

    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.map((i) {
        if (items.any((item) => item.entity.id == i.entity.id)) {
          i.isSelected = false;
        }

        return i;
      }),
    );
  }

  Future<void> resetSelection() async {
    candidatesNotifier.value = {};

    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.map((i) {
        i.isSelected = false;

        return i;
      }),
    );
  }

  Future<void> selectAll(Iterable<Item<E>> items) async {
    candidatesNotifier.value.addAll(items);

    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.map((item) {
        if (items.contains(item)) {
          item.isSelected = true;
        }

        return item;
      }),
    );
  }

  Future<void> selectExclusively(Item<E> item) async {
    candidatesNotifier.value = {item};

    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.map((i) {
        i.isSelected = item.entity.id == i.entity.id;
        return i;
      }),
    );
  }

  Future<void> select(Item<E> item) async {
    return selectAll([item]);
  }

  Future<void> previous() => execute((pager) async {
    if (pager == null) return init();

    final query = await queryEntities.execute(filter: filter);
    final models = query.hits.map((entity) => itemBuilder(entity)).toList();

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

  Item<E> itemBuilder(E entity) {
    return Item<E>(entity);
  }

  @override
  dispose() {
    super.dispose();
    filterNotifier.dispose();
    selectNotifier.dispose();
    candidatesNotifier.dispose();
  }
}
