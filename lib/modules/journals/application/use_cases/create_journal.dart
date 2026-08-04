import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/events/journal_created.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class CreateJournalParams {
  final String name;
  final String holderName;
  final double balance;
  final String assetId;

  CreateJournalParams({
    required this.name,
    required this.holderName,
    required this.balance,
    required this.assetId,
  });
}

class CreateJournal extends UseCase<CreateJournalParams, Journal> {
  final JournalRepository journalRepository;
  final DomainEventPublisher eventPublisher;
  final UnitOfWork unitOfWork;

  factory CreateJournal.fromContainer(DependencyContainer c) {
    return CreateJournal(
      journalRepository: c.get<JournalRepository>(),
      eventPublisher: c.get<DomainEventPublisher>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  CreateJournal({
    required this.journalRepository,
    required this.eventPublisher,
    required this.unitOfWork,
  });

  @override
  Future<Journal> execute(CreateJournalParams params) async {
    return unitOfWork.execute(() async {
      final journal = Journal.create(
        name: params.name,
        holderName: params.holderName,
        balance: params.balance,
        assetId: params.assetId,
      );

      await journalRepository.save(journal);

      eventPublisher.raise(JournalCreated.fromJournal(journal));

      return journal;
    });
  }
}
