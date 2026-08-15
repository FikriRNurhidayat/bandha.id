import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/view_models/async_view_model.dart';
import 'package:flutter/widgets.dart';

class AsyncListProvider<E extends Entity>
    extends AsyncViewModel<List<Item<E>>> {
  final QueryEntities<E> queryEntities;
  final ValueNotifier<DataFilter> filterNotifier = ValueNotifier({});

  AsyncListProvider({required this.queryEntities});

  factory AsyncListProvider.build(DependencyContainer c) {
    return AsyncListProvider<E>(queryEntities: c.get<QueryEntities<E>>());
  }

  factory AsyncListProvider.of(BuildContext context) {
    return DependencyInjector.of(context).get<AsyncListProvider<E>>();
  }

  DataFilter get filter => filterNotifier.value;

  Future<List<Item<E>>> init() async {
    final query = await queryEntities.execute(filter: filter);
    final models = query.hits.map((entity) => Item<E>(entity)).toList();
    return List<Item<E>>.of(models);
  }

  void setFilter(DataFilter filter) {
    filterNotifier.value = filter;
  }

  Future<void> query() => execute((x) => init());
}
