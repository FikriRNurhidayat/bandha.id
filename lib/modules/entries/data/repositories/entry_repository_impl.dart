import 'package:bandha/core/data/repository_impl.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/entities/controlable.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/domain/types/data_list.dart';
import 'package:bandha/core/domain/types/data_query.dart';
import 'package:bandha/modules/entries/data/data_sources/entry_local_storage.dart';
import 'package:bandha/modules/entries/data/services/entry_hydrator.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_reader.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';

class EntryRepositoryImpl extends HydratedRepositoryImpl<Entry>
    implements EntryRepository, EntryReader {
  @override
  final EntryLocalStorage localStorage;

  @override
  final EntryHydrator hydrator;

  EntryRepositoryImpl({required this.localStorage, required this.hydrator});

  factory EntryRepositoryImpl.fromContainer(DependencyContainer c) {
    return EntryRepositoryImpl(
      localStorage: c.get<EntryLocalStorage>(),
      hydrator: c.get<EntryHydrator>(),
    );
  }

  @override
  Future<DataList<Entry>> queryByControlable(
    Controllable controllable,
    DataQuery? query,
  ) async {
    return queryByController(controllable.controller, query);
  }

  @override
  Future<DataList<Entry>> queryByController(
    Controller controller,
    DataQuery? query,
  ) async {
    final dataList = await localStorage.queryByController(controller, query);
    return dataList.copyWith(hits: await hydrator.hydrateAll(dataList.hits));
  }

  @override
  Future<Iterable<Entry>> controllableBy(
    Controllable controllable, {
    DataFilter? filter,
  }) async {
    return controlledBy(controllable.controller, filter: filter);
  }

  @override
  Future<Iterable<Entry>> controlledBy(
    Controller controller, {
    DataFilter? filter,
  }) async {
    final entries = await localStorage.controlledBy(controller);
    return hydrator.hydrateAll(entries);
  }
}
