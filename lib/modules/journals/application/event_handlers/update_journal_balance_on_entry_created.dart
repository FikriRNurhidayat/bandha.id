import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class UpdateJournalBalanceOnEntryCreated extends EventHandler<EntryCreated> {
  final JournalRepository journalRepository;

  UpdateJournalBalanceOnEntryCreated(this.journalRepository);

  factory UpdateJournalBalanceOnEntryCreated.build(
    DependencyContainer c,
  ) {
    return UpdateJournalBalanceOnEntryCreated(
      c.get<JournalRepository>(),
    );
  }

  @override
  Future<void> handle(EntryCreated event) async {
    if (event.skip) {
      return;
    }

    await journalRepository.incrementBalance(
      event.snapshot.journalId,
      event.snapshot.amount,
    );
  }
}
