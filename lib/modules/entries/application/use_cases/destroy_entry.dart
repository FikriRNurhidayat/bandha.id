import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';

class DestroyEntryParams {
  final String id;

  DestroyEntryParams(this.id);
}

class DestroyEntry extends UseCase<DestroyEntryParams, void> {
  final EntryRepository entryRepository;
  final UnitOfWork unitOfWork;
  final DomainEventPublisher eventPublisher;

  DestroyEntry({
    required this.entryRepository,
    required this.unitOfWork,
    required this.eventPublisher,
  });

  factory DestroyEntry.fromContainer(DependencyContainer c) {
    return DestroyEntry(
      entryRepository: c.get<EntryRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      eventPublisher: c.get<DomainEventPublisher>(),
    );
  }

  @override
  Future<void> execute(DestroyEntryParams params) async {
    return unitOfWork.execute<void>(() async {
      final entry = await entryRepository.get(params.id);
      await entryRepository.destroy(entry);
      await eventPublisher.raise(EntryDestroyed.fromEntry(entry));
    });
  }
}
