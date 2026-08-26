import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class CreateEntry {
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

  factory CreateEntry.build(DependencyContainer c) {
    return CreateEntry(
      unitOfWork: c.get<UnitOfWork>(),
      entryRepository: c.get<EntryRepository>(),
      eventPublisher: c.get<DomainEventPublisher>(),
      journalReader: c.get<JournalReader>(),
      labelReader: c.get<LabelReader>(),
      categoryReader: c.get<CategoryReader>(),
    );
  }

  Future<Entry> execute({
    required String note,
    required double amount,
    required EntryStatus status,
    required String journalId,
    required String categoryId,
    required DateTime issuedAt,
    Iterable<String> labelIds = const [],
  }) {
    return unitOfWork.execute(() async {
      final category = await categoryReader.get(categoryId);
      final journal = await journalReader.get(journalId);
      final labels = await labelReader.getAll(labelIds);

      final entry = Entry.create(
        note: note,
        amount: amount,
        status: status,
        journalId: journal.id,
        categoryId: categoryId,
        issuedAt: issuedAt,
      ).withCategory(category).withJournal(journal).withLabels(labels);

      await entryRepository.save(entry);
      await eventPublisher.raise(EntryCreated.fromEntry(entry));

      return entry;
    });
  }
}
