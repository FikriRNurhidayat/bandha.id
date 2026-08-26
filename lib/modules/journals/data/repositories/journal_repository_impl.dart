import 'package:bandha/core/data/repository_impl.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/journals/data/data_sources/journal_local_storage.dart';
import 'package:bandha/modules/journals/data/services/journal_hydrator.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class JournalRepositoryImpl extends HydratedRepositoryImpl<Journal>
    implements JournalRepository, JournalReader {
  @override
  final JournalLocalStorage localStorage;

  @override
  final JournalHydrator hydrator;

  JournalRepositoryImpl({required this.localStorage, required this.hydrator});

  factory JournalRepositoryImpl.build(DependencyContainer c) {
    return JournalRepositoryImpl(
      localStorage: c.get<JournalLocalStorage>(),
      hydrator: c.get<JournalHydrator>(),
    );
  }

  @override
  Future<void> balance(String id) {
    return localStorage.balance(id);
  }

  @override
  Future<void> incrementBalance(String id, double delta) {
    return localStorage.incrementBalance(id, delta);
  }
}
