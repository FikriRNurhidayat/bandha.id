import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_models/async_pager_view_model.dart';
import 'package:bandha/modules/journals/application/use_cases/query_journals.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/presentation/models/journal_display.dart';
import 'package:flutter/widgets.dart';

class JournalListViewModel
    extends AsyncPagerViewModel<Journal, JournalDisplay> {
  @override
  final QueryJournals queryEntities;

  JournalListViewModel({required this.queryEntities});

  factory JournalListViewModel.of(BuildContext context) =>
      DependencyInjector.of(context).get<JournalListViewModel>();
  factory JournalListViewModel.fromContainer(DependencyContainer c) =>
      JournalListViewModel(queryEntities: c.get<QueryJournals>());

  @override
  JournalDisplay model(Journal journal) {
    return JournalDisplay.of(journal);
  }
}
