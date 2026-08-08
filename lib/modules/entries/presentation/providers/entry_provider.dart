import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_models/async_pager_view_model.dart';
import 'package:bandha/modules/entries/application/use_cases/query_entries.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/models/entry_display.dart';
import 'package:flutter/widgets.dart';

class EntryProvider extends AsyncPagerViewModel<Entry, EntryDisplay> {
  @override
  final QueryEntries queryEntities;

  EntryProvider({required this.queryEntities});

  factory EntryProvider.of(BuildContext context) {
    return DependencyInjector.of(context).get<EntryProvider>();
  }

  factory EntryProvider.fromContainer(DependencyContainer c) {
    return EntryProvider(queryEntities: c.get<QueryEntries>());
  }

  @override
  EntryDisplay model(Entry entry) {
    return EntryDisplay.of(entry);
  }
}
