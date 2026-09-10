import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/constants/system_categories.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/types/controller.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';
import 'package:bandha/modules/entries/domain/value_objects/entry_snapshot.dart';
import 'package:bandha/modules/journals/domain/events/journal_created.dart';

class CreateEntryOnJournalCreated extends EventHandler<JournalCreated> {
  final EntryRepository entryRepository;
  final DomainEventPublisher eventPublisher;

  CreateEntryOnJournalCreated({
    required this.entryRepository,
    required this.eventPublisher,
  });

  factory CreateEntryOnJournalCreated.build(DependencyContainer c) {
    return CreateEntryOnJournalCreated(
      entryRepository: c.get<EntryRepository>(),
      eventPublisher: c.get<DomainEventPublisher>(),
    );
  }

  @override
  Future<void> handle(JournalCreated event) async {
    if (event.snapshot.balance == 0) {
      return;
    }

    final entry = Entry.readonly(
      note: "Balance adjustment",
      amount: event.snapshot.balance,
      status: EntryStatus.done,
      controller: Controller(id: event.journalId, type: "Journal"),
      journalId: event.journalId,
      categoryId: SystemCategories.adjustmentId,
      issuedAt: event.occurredAt,
    );

    await entryRepository.save(entry);

    eventPublisher.raise(
      EntryCreated(
        entryId: entry.id,
        snapshot: EntrySnapshot(
          journalId: event.journalId,
          assetId: event.snapshot.assetId,
          amount: event.snapshot.balance,
        ),
        skip: true,
      ),
    );
  }
}
