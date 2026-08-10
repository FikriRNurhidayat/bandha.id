import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class GetJournal extends GetEntity<Journal> {
  final JournalRepository journalRepository;

  GetJournal({required this.journalRepository}) : super(journalRepository);

  @override
  Repository<Journal> get repository => journalRepository;

  factory GetJournal.build(DependencyContainer c) {
    return GetJournal(journalRepository: c.get<JournalRepository>());
  }
}
