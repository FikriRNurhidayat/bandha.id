import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/assets/domain/ports/asset_reader.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/domain/events/journal_created.dart';
import 'package:bandha/modules/journals/domain/repositories/journal_repository.dart';

class CreateJournal {
  final AssetReader assetReader;
  final JournalRepository journalRepository;
  final DomainEventPublisher eventPublisher;
  final UnitOfWork unitOfWork;

  factory CreateJournal.build(DependencyContainer c) {
    return CreateJournal(
      journalRepository: c.get<JournalRepository>(),
      eventPublisher: c.get<DomainEventPublisher>(),
      unitOfWork: c.get<UnitOfWork>(),
      assetReader: c.get<AssetReader>(),
    );
  }

  CreateJournal({
    required this.assetReader,
    required this.eventPublisher,
    required this.journalRepository,
    required this.unitOfWork,
  });

  Future<Journal> execute({
    required String name,
    required String holderName,
    required double balance,
    required String assetId,
  }) async {
    return unitOfWork.execute(() async {
      final asset = await assetReader.get(assetId);
      final journal = Journal.create(
        name: name,
        holderName: holderName,
        balance: balance,
        assetId: assetId,
      ).withAsset(asset);

      await journalRepository.save(journal);
      await eventPublisher.raise(JournalCreated.fromJournal(journal));

      return journal;
    });
  }
}
