import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:bandha/core/presentation/view_models/async_tile_view_model.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/journals/application/event_handlers/update_journal_balance_on_entry_created.dart';
import 'package:bandha/modules/journals/application/event_handlers/update_journal_balance_on_entry_destroyed.dart';
import 'package:bandha/modules/journals/application/event_handlers/update_journal_balance_on_entry_updated.dart';
import 'package:bandha/modules/journals/application/use_cases/create_journal.dart';
import 'package:bandha/modules/journals/application/use_cases/destroy_journal.dart';
import 'package:bandha/modules/journals/application/use_cases/get_journal.dart';
import 'package:bandha/modules/journals/application/use_cases/query_journals.dart';
import 'package:bandha/modules/journals/application/use_cases/update_journal.dart';
import 'package:bandha/modules/journals/data/data_sources/journal_local_storage.dart';
import 'package:bandha/modules/journals/data/data_sources/journal_sqlite_storage.dart';
import 'package:bandha/modules/journals/data/repositories/journal_repository_impl.dart';
import 'package:bandha/modules/journals/data/services/journal_hydrator.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';
import 'package:bandha/modules/journals/presentation/view_models/journal_editor_view_model.dart';

class JournalModule extends Module {
  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<JournalSqliteStorage>(JournalSqliteStorage.build(c));
    c.registerSingleton<JournalLocalStorage>(c.get<JournalSqliteStorage>());
    c.registerSingleton<JournalHydrator>(JournalHydrator.build(c));
    c.registerSingleton<JournalRepositoryImpl>(JournalRepositoryImpl.build(c));
    c.registerSingleton<JournalRepository>(c.get<JournalRepositoryImpl>());
    c.registerSingleton<JournalReader>(c.get<JournalRepositoryImpl>());
  }

  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<CreateJournal>(CreateJournal.build(c));
    c.registerSingleton<UpdateJournal>(UpdateJournal.build(c));
    c.registerSingleton<GetEntity<Journal>>(GetJournal.build(c));
    c.registerSingleton<DestroyEntity<Journal>>(DestroyJournal.build(c));
    c.registerSingleton<QueryEntities<Journal>>(QueryJournals.build(c));
    c.registerFactory<JournalEditorViewModel>(JournalEditorViewModel.build);
    c.registerFactory<AsyncListViewModel<Journal>>(
      AsyncListViewModel<Journal>.build,
    );
    c.registerFactory<AsyncTileViewModel<Journal>>(
      AsyncTileViewModel<Journal>.build,
    );
    c.registerFactory<AsyncEditorViewModel<Journal>>(
      JournalEditorViewModel.build,
    );
  }

  @override
  Future<void> event(DependencyContainer c, DomainEventPublisher e) async {
    e.register<EntryCreated>(UpdateJournalBalanceOnEntryCreated.build(c));
    e.register<EntryDestroyed>(UpdateJournalBalanceOnEntryDestroyed.build(c));
    e.register<EntryUpdated>(UpdateJournalBalanceOnEntryUpdated.build(c));
  }
}
