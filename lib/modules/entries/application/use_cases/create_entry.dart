import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class CreateEntryParams {
  final String note;
  final double amount;
  final EntryStatus status;
  final String journalId;
  final String categoryId;
  final DateTime issuedAt;
  final Iterable<String> labelIds;

  CreateEntryParams({
    required this.note,
    required this.amount,
    required this.status,
    required this.journalId,
    required this.categoryId,
    required this.issuedAt,
    this.labelIds = const [],
  });
}

class CreateEntry extends UseCase<CreateEntryParams, Entry> {
  final UnitOfWork unitOfWork;
  final EntryRepository entryRepository;
  final DomainEventPublisher eventPublisher;
  final JournalReader journalReader;
  final LabelReader labelReader;
  final CategoryReader categoryReader;

  CreateEntry({
    required this.unitOfWork,
    required this.entryRepository,
    required this.eventPublisher,
    required this.journalReader,
    required this.labelReader,
    required this.categoryReader,
  });

  factory CreateEntry.fromContainer(DependencyContainer c) {
    return CreateEntry(
      unitOfWork: c.get<UnitOfWork>(),
      entryRepository: c.get<EntryRepository>(),
      eventPublisher: c.get<DomainEventPublisher>(),
      journalReader: c.get<JournalReader>(),
      labelReader: c.get<LabelReader>(),
      categoryReader: c.get<CategoryReader>(),
    );
  }

  @override
  Future<Entry> execute(CreateEntryParams params) {
    return unitOfWork.execute(() async {
      final category = await categoryReader.get(params.categoryId);
      final journal = await journalReader.get(params.journalId);
      final labels = await labelReader.getAll(params.labelIds);

      final entry = Entry.create(
        note: params.note,
        amount: params.amount,
        status: params.status,
        journalId: journal.id,
        categoryId: params.categoryId,
        issuedAt: params.issuedAt,
      ).withCategory(category).withJournal(journal).withLabels(labels);

      await entryRepository.save(entry);
      eventPublisher.raise(EntryCreated.fromEntry(entry));

      return entry;
    });
  }
}
