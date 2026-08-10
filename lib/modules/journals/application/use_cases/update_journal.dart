import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/events/journal_updated.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class UpdateJournal {
  final JournalRepository journalRepository;
  final DomainEventPublisher eventPublisher;
  final UnitOfWork unitOfWork;

  factory UpdateJournal.build(DependencyContainer c) {
    return UpdateJournal(
      journalRepository: c.get<JournalRepository>(),
      eventPublisher: c.get<DomainEventPublisher>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  UpdateJournal({
    required this.journalRepository,
    required this.eventPublisher,
    required this.unitOfWork,
  });

  Future<Journal> execute(
    String id, {
    String? name,
    String? holderName,
    double? balance,
  }) async {
    return unitOfWork.execute(() async {
      final before = await journalRepository.get(id);

      final after = before.copyWith(
        name: name,
        holderName: holderName,
        balance: balance,
      );

      await journalRepository.save(after);

      eventPublisher.raise(JournalUpdated.of(before, after));

      return after;
    });
  }
}
