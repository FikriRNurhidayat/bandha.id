import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_list_provider.dart';
import 'package:flutter/material.dart';

class AsyncSelectProvider<E extends Entity> extends AsyncListProvider<E> {
  AsyncSelectProvider({required super.queryEntities});

  factory AsyncSelectProvider.of(BuildContext context) {
    return DependencyInjector.of(context).get<AsyncSelectProvider<E>>();
  }

  factory AsyncSelectProvider.build(DependencyContainer c) {
    return AsyncSelectProvider<E>(queryEntities: c.get<QueryEntities<E>>());
  }

  Future<void> addAll(Iterable<Item<E>> items) async {
    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.followedBy(items).toList(),
    );
  }

  Future<void> add(Item<E> item) async {
    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.followedBy([item]).toList(),
    );
  }

  Future<void> initialValue(Item<E> item) async {
    item.isSelected = true;
    notifier.value = AsyncSnapshot.withData(ConnectionState.done, [item]);
  }

  Future<void> selectAll(Iterable<Item<E>> items) async {
    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.map((i) {
        if (items.any((item) => i.entity.id == item.entity.id)) {
          i.isSelected = true;
        }

        return i;
      }).toList(),
    );
  }

  Future<void> select(Item<E> item) async {
    return selectAll([item]);
  }

  Future<void> deselectAll(Iterable<Item<E>> items) async {
    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.map((i) {
        if (items.any((item) => i.entity.id == item.entity.id)) {
          i.isSelected = false;
        }

        return i;
      }).toList(),
    );
  }

  Future<void> deselect(Item<E> item) async {
    return deselectAll([item]);
  }
}
