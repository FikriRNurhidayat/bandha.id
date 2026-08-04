import 'package:bandha/core/application/event_handler.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';
import 'package:bandha/modules/funds/domain/events/fund_destroyed.dart';

class DestroyEntryOnFundDestroyed extends EventHandler<FundDestroyed> {
  final DomainEventPublisher eventPublisher;
  final EntryRepository entryRepository;

  DestroyEntryOnFundDestroyed({
    required this.eventPublisher,
    required this.entryRepository,
  });

  factory DestroyEntryOnFundDestroyed.fromContainer(DependencyContainer c) {
    return DestroyEntryOnFundDestroyed(
      eventPublisher: c.get<DomainEventPublisher>(),
      entryRepository: c.get<EntryRepository>(),
    );
  }

  @override
  Future<void> handle(FundDestroyed event) async {
    final entries = await entryRepository.controlledBy(event.controller);
    await entryRepository.destroyAll(entries);
    await eventPublisher.raiseAll(
      entries.map((e) => EntryDestroyed.fromEntry(e)),
    );
  }
}
