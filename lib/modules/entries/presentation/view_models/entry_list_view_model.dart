import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/material.dart';

class EntryListViewModel extends AsyncListViewModel<Entry> {
  EntryListViewModel({
    required super.queryEntities,
    required super.destroyEntity,
    required super.getEntity,
  });

  factory EntryListViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<EntryListViewModel>();
  }

  factory EntryListViewModel.build(DependencyContainer c) {
    return EntryListViewModel(
      queryEntities: c.get<QueryEntities<Entry>>(),
      destroyEntity: c.get<DestroyEntity<Entry>>(),
      getEntity: c.get<GetEntity<Entry>>(),
    );
  }

  @override
  Item<Entry> itemBuilder(Entry entity) {
    return Item<Entry>(entity, readOnly: entity.readOnly);
  }
}
