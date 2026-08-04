import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/events/journal_updated.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class UpdateJournalParams {
  final String id;
  final String? name;
  final String? holderName;
  final double? balance;

  UpdateJournalParams(this.id, {this.name, this.holderName, this.balance});
}

class UpdateJournal extends UseCase<UpdateJournalParams, Journal> {
  final JournalRepository journalRepository;
  final DomainEventPublisher eventPublisher;
  final UnitOfWork unitOfWork;

  factory UpdateJournal.fromContainer(DependencyContainer c) {
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

  @override
  Future<Journal> execute(UpdateJournalParams params) async {
    return unitOfWork.execute(() async {
      final before = await journalRepository.get(params.id);

      final after = before.copyWith(
        name: params.name,
        holderName: params.holderName,
        balance: params.balance,
      );

      await journalRepository.save(after);

      eventPublisher.raise(JournalUpdated.of(before, after));

      return after;
    });
  }
}
