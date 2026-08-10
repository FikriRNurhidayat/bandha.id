import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class DestroyJournal extends DestroyEntity<Journal> {
  DestroyJournal(super.repository);

  factory DestroyJournal.build(DependencyContainer c) {
    return DestroyJournal(c.get<JournalRepository>());
  }
}
