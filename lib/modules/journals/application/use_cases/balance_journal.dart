import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class BalanceJournal {
  final JournalRepository journalRepository;

  BalanceJournal({required this.journalRepository});

  factory BalanceJournal.build(DependencyContainer c) {
    return BalanceJournal(
      journalRepository: c.get<JournalRepository>(),
    );
  }

  Future<void> execute(String id) async {
    await journalRepository.balance(id);
  }
}
