import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class UpdateJournalBalanceOnEntryDestroyed
    extends EventHandler<EntryDestroyed> {
  final JournalRepository journalRepository;

  UpdateJournalBalanceOnEntryDestroyed(this.journalRepository);

  factory UpdateJournalBalanceOnEntryDestroyed.fromContainer(
    DependencyContainer c,
  ) {
    return UpdateJournalBalanceOnEntryDestroyed(
      c.get<JournalRepository>(),
    );
  }

  @override
  Future<void> handle(EntryDestroyed event) async {
    await journalRepository.incrementBalance(
      event.snapshot.journalId,
      -event.snapshot.amount,
    );
  }

  @override
  Future<void> handleAll(Iterable<EntryDestroyed> events) async {
    final Set<String> journalIds = {};
    final Map<String, List<EntryDestroyed>> journalEvents = {};

    for (final event in events) {
      journalIds.add(event.snapshot.journalId);
      journalEvents
          .putIfAbsent(event.snapshot.journalId, () => <EntryDestroyed>[event])
          .add(event);
    }

    final journals = await journalRepository.getAll(journalIds);
    await journalRepository.saveAll(
      journals.map((journal) {
        final events = journalEvents[journal.id];
        if (events == null) return journal;

        double delta = 0;
        for (final event in events) {
          delta += event.snapshot.amount;
        }

        if (delta == 0) return journal;

        return journal.copyWith(balance: journal.balance - delta);
      }),
    );
  }
}
