import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class UpdateJournalBalanceOnEntryUpdated extends EventHandler<EntryUpdated> {
  final JournalRepository journalRepository;

  UpdateJournalBalanceOnEntryUpdated(this.journalRepository);

  factory UpdateJournalBalanceOnEntryUpdated.fromContainer(
    DependencyContainer c,
  ) {
    return UpdateJournalBalanceOnEntryUpdated(c.get<JournalRepository>());
  }

  @override
  Future<void> handle(EntryUpdated event) async {
    if (!event.hasBalanceImpact) {
      return;
    }

    await journalRepository.incrementBalance(
      event.before.journalId,
      -event.before.amount,
    );

    await journalRepository.incrementBalance(
      event.after.journalId,
      event.after.amount,
    );
  }
}
