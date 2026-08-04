import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class BalanceJournalParams {
  final String id;

  BalanceJournalParams(this.id);
}

class BalanceJournal extends UseCase<BalanceJournalParams, void> {
  final JournalRepository journalRepository;

  BalanceJournal({required this.journalRepository});

  factory BalanceJournal.fromContainer(DependencyContainer c) {
    return BalanceJournal(
      journalRepository: c.get<JournalRepository>(),
    );
  }

  @override
  Future<void> execute(BalanceJournalParams params) async {
    await journalRepository.balance(params.id);
  }
}
