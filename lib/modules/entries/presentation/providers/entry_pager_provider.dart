import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/presentation/providers/async_pager_provider.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/widgets.dart';

class EntryPagerProvider extends AsyncPagerProvider<Entry> {
  EntryPagerProvider({required super.queryEntities});

  factory EntryPagerProvider.build(DependencyContainer c) {
    return EntryPagerProvider(queryEntities: c.get<QueryEntities<Entry>>());
  }

  factory EntryPagerProvider.of(BuildContext context) {
    return DependencyInjector.of(context).get<EntryPagerProvider>();
  }

  Future<void> controlledBy(Controllable controllable) async {
    filterNotifier.value = controllable.dataFilter;
    return query();
  }
}
