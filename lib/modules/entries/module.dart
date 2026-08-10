import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/presentation/providers/async_list_provider.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:bandha/modules/entries/application/event_handlers/create_entry_on_journal_created.dart';
import 'package:bandha/modules/entries/application/event_handlers/create_entry_on_journal_updated.dart';
import 'package:bandha/modules/entries/application/event_handlers/destroy_entry_on_fund_destroyed.dart';
import 'package:bandha/modules/entries/application/use_cases/create_entry.dart';
import 'package:bandha/modules/entries/application/use_cases/destroy_entry.dart';
import 'package:bandha/modules/entries/application/use_cases/get_entry.dart';
import 'package:bandha/modules/entries/application/use_cases/query_entries.dart';
import 'package:bandha/modules/entries/application/use_cases/update_entry.dart';
import 'package:bandha/modules/entries/data/data_sources/entry_local_storage.dart';
import 'package:bandha/modules/entries/data/data_sources/entry_sqlite_storage.dart';
import 'package:bandha/modules/entries/data/repositories/entry_repository_impl.dart';
import 'package:bandha/modules/entries/data/services/entry_hydrator.dart';
import 'package:bandha/modules/entries/data/services/entry_writer_impl.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_reader.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';
import 'package:bandha/modules/entries/presentation/providers/entry_list_provider.dart';
import 'package:bandha/modules/entries/presentation/view_models/entry_editor_view_model.dart';
import 'package:bandha/modules/funds/domain/events/fund_destroyed.dart';
import 'package:bandha/modules/journals/domain/events/journal_created.dart';
import 'package:bandha/modules/journals/domain/events/journal_updated.dart';

class EntryModule extends Module {
  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<EntrySqliteStorage>(EntrySqliteStorage.build(c));
    c.registerSingleton<EntryLocalStorage>(c.get<EntrySqliteStorage>());
    c.registerSingleton<EntryHydrator>(EntryHydrator.build(c));
    c.registerSingleton<EntryRepositoryImpl>(EntryRepositoryImpl.build(c));
    c.registerSingleton<EntryRepository>(c.get<EntryRepositoryImpl>());
    c.registerSingleton<EntryReader>(c.get<EntryRepositoryImpl>());
    c.registerSingleton<EntryWriterImpl>(EntryWriterImpl.build(c));
    c.registerSingleton<EntryWriter>(c.get<EntryWriterImpl>());
  }

  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<CreateEntry>(CreateEntry.build(c));
    c.registerSingleton<UpdateEntry>(UpdateEntry.build(c));
    c.registerSingleton<DestroyEntity<Entry>>(DestroyEntry.build(c));
    c.registerSingleton<GetEntity<Entry>>(GetEntry.build(c));
    c.registerSingleton<QueryEntities<Entry>>(QueryEntries.build(c));
    c.registerFactory<AsyncListViewModel<Entry>>(
      AsyncListViewModel<Entry>.build,
    );
    c.registerFactory<EntryListProvider>(EntryListProvider.build);
    c.registerFactory<AsyncListProvider<Entry>>(EntryListProvider.build);
    c.registerFactory<AsyncEditorViewModel<Entry>>(EntryEditorViewModel.build);
  }

  @override
  Future<void> event(DependencyContainer c, DomainEventPublisher e) async {
    e.register<JournalCreated>(CreateEntryOnJournalCreated.build(c));
    e.register<JournalUpdated>(CreateEntryOnJournalUpdated.build(c));
    e.register<FundDestroyed>(DestroyEntryOnFundDestroyed.build(c));
  }
}
