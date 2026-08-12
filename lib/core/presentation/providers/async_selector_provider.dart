import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_list_provider.dart';
import 'package:flutter/material.dart';

class AsyncSelectorProvider<E extends Entity> extends AsyncListProvider<E> {
  AsyncSelectorProvider._({required super.queryEntities});

  factory AsyncSelectorProvider.of(BuildContext context) {
    return DependencyInjector.of(context).get<AsyncSelectorProvider<E>>();
  }

  factory AsyncSelectorProvider.build(DependencyContainer c) {
    return AsyncSelectorProvider<E>._(queryEntities: c.get<QueryEntities<E>>());
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

  Future<void> select(Item<E> item) async {
    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData
          .map((i) => i.selected(i.entity.id == item.entity.id))
          .toList(),
    );
  }

  Future<void> deselect(Item<E> item) async {
    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData
          .map((i) => i.notSelected(i.entity.id == item.entity.id))
          .toList(),
    );
  }
}
