import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class QueryJournals extends QueryEntities<Journal> {
  final JournalRepository journalRepository;

  QueryJournals({required this.journalRepository}) : super(journalRepository);

  @override
  Repository<Journal> get repository => journalRepository;

  factory QueryJournals.build(DependencyContainer c) {
    return QueryJournals(journalRepository: c.get<JournalRepository>());
  }
}
