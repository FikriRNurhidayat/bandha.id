import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';

class DestroyEntry extends DestroyEntity<Entry> {
  final UnitOfWork unitOfWork;
  final DomainEventPublisher eventPublisher;

  DestroyEntry(
    super.repository, {
    required this.unitOfWork,
    required this.eventPublisher,
  });

  factory DestroyEntry.build(DependencyContainer c) {
    return DestroyEntry(
      c.get<EntryRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      eventPublisher: c.get<DomainEventPublisher>(),
    );
  }

  @override
  Future<void> execute(String id) async {
    return unitOfWork.execute<void>(() async {
      final entry = await repository.get(id);
      await repository.destroy(entry);
      await eventPublisher.raise(EntryDestroyed.fromEntry(entry));
    });
  }
}
