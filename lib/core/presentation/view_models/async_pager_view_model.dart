import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/presentation/types/pager.dart';
import 'package:bandha/core/presentation/view_models/async_view_model.dart';
import 'package:flutter/widgets.dart';

abstract class AsyncPagerViewModel<Entity, UiModel>
    extends AsyncViewModel<Pager<UiModel>> {
  @override
  final notifier = ValueNotifier<AsyncSnapshot<Pager<UiModel>>>(
    AsyncSnapshot.nothing(),
  );
  abstract final QueryEntities<Entity> queryEntities;
  UiModel model(Entity entity);

  Future<Pager<UiModel>> init() async {
    final query = await queryEntities.execute(null);
    final models = query.hits.map((entity) => model(entity)).toList();
    final pager = Pager<UiModel>.of(models);
    return pager.withPreviousCursor(query.previous).withNextCursor(query.next);
  }

  Pager<UiModel> get pager => notifier.value.requireData;

  Future<void> query() => execute((_) => init());

  Future<void> next() => execute((pager) async {
    if (pager == null) return init();

    final query = await queryEntities.execute(null);
    final models = query.hits.map((entity) => model(entity)).toList();

    return pager
        .withNext(models)
        .withPreviousCursor(query.previous)
        .withNextCursor(query.next);
  });

  Future<void> previous() => execute((pager) async {
    if (pager == null) return init();

    final query = await queryEntities.execute(null);
    final models = query.hits.map((entity) => model(entity)).toList();

    return pager
        .withPrevious(models)
        .withPreviousCursor(query.previous)
        .withNextCursor(query.next);
  });
}
