import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/presentation/providers/async_list_provider.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/widgets.dart';

class EntryListProvider extends AsyncListProvider<Entry> {
  EntryListProvider({required super.queryEntities});

  factory EntryListProvider.build(DependencyContainer c) {
    return EntryListProvider(queryEntities: c.get<QueryEntities<Entry>>());
  }

  factory EntryListProvider.of(BuildContext context) {
    return DependencyInjector.of(context).get<EntryListProvider>();
  }

  Future<void> controlledBy(Controllable controllable) async {
    filterNotifier.value = controllable.dataFilter;
    return query();
  }
}
