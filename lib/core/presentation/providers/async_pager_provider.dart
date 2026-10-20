import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/types/pager.dart';
import 'package:bandha/core/presentation/view_models/async_view_model.dart';
import 'package:flutter/widgets.dart';

typedef AsyncPagerFormatter<E extends Entity> = Item<E> Function(Item<E>);

class AsyncPagerProvider<E extends Entity>
    extends AsyncViewModel<Pager<Item<E>>> {
  AsyncPagerProvider({required this.queryEntities});

  final QueryEntities<E> queryEntities;
  final ValueNotifier<DataFilter> filterNotifier = ValueNotifier({});
  AsyncPagerFormatter<E>? formatter;

  factory AsyncPagerProvider.build(DependencyContainer c) {
    return AsyncPagerProvider<E>(queryEntities: c.get<QueryEntities<E>>());
  }

  factory AsyncPagerProvider.of(BuildContext context) {
    return DependencyInjector.of(context).get<AsyncPagerProvider<E>>();
  }

  DataFilter get filter => filterNotifier.value;

  Future<Pager<Item<E>>> init() async {
    final query = await queryEntities.execute(filter: filter);
    final models = query.hits.map((entity) {
      final item = Item<E>(entity);
      return item;
    }).toList();
    return Pager<Item<E>>.of(
      models,
    ).withPreviousCursor(query.previous).withNextCursor(query.next);
  }

  Future<void> next() => execute((pager) async {
    debugPrint("pager is $pager");
    if (pager == null) return init();

    final query = await queryEntities.execute(
      filter: filter,
      cursor: pager.nextCursor,
    );
    final models = query.hits.map((entity) => Item<E>(entity)).toList();

    final newPager = pager
        .withNext(models)
        .withPreviousCursor(
          pager.isFilled ? query.previous : pager.previousCursor,
        )
        .withNextCursor(query.next);

    return newPager;
  });

  Future<void> previous() => execute((pager) async {
    if (pager == null) return init();

    final query = await queryEntities.execute(
      filter: filter,
      cursor: pager.previousCursor,
    );
    final models = query.hits.map((entity) => Item<E>(entity)).toList();

    return pager
        .withPrevious(models)
        .withPreviousCursor(query.previous)
        .withNextCursor(query.next);
  });

  AsyncPagerProvider<E> setFormatter(AsyncPagerFormatter<E>? formatter) {
    if (formatter != null) {
      this.formatter = formatter;
    }

    return this;
  }

  AsyncPagerProvider<E> setFilter(DataFilter filter) {
    filterNotifier.value = filter;
    return this;
  }

  Future<void> query() => execute((x) => init());

  @override
  dispose() {
    super.dispose();
    filterNotifier.dispose();
  }
}
