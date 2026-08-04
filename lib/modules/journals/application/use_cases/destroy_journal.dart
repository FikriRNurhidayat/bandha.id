import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class DestroyJournalParams {
  final String id;

  DestroyJournalParams(this.id);
}

class DestroyJournal extends UseCase<DestroyJournalParams, void> {
  final JournalRepository journalRepository;
  final UnitOfWork unitOfWork;

  DestroyJournal({required this.journalRepository, required this.unitOfWork});

  factory DestroyJournal.fromContainer(DependencyContainer c) {
    return DestroyJournal(
      journalRepository: c.get<JournalRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  @override
  Future<void> execute(DestroyJournalParams params) async {
    return unitOfWork.execute(() async {
      final journal = await journalRepository.get(params.id);
      await journalRepository.destroy(journal);
    });
  }
}
