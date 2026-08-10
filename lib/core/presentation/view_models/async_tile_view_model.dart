import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/view_models/async_view_model.dart';
import 'package:flutter/widgets.dart';

class AsyncTileViewModel<E extends Entity> extends AsyncViewModel<Item<E>> {
  final GetEntity<E> getEntity;

  AsyncTileViewModel._({required this.getEntity});

  factory AsyncTileViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<AsyncTileViewModel<E>>();
  }

  factory AsyncTileViewModel.build(DependencyContainer c) {
    return AsyncTileViewModel<E>._(getEntity: c.get<GetEntity<E>>());
  }

  Future<Item<E>> init(String id) async {
    final entity = await getEntity.execute(id);
    return Item<E>(entity);
  }

  Future<void> query(String id) => execute((previous) async {
    return init(id);
  });

  Item<E> get pager => notifier.value.requireData;
}
