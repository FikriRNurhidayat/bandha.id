import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class UpdateEntry {
  final EntryRepository entryRepository;
  final UnitOfWork unitOfWork;
  final DomainEventPublisher eventPublisher;
  final JournalReader journalReader;
  final LabelReader labelReader;
  final CategoryReader categoryReader;

  UpdateEntry({
    required this.entryRepository,
    required this.unitOfWork,
    required this.eventPublisher,
    required this.journalReader,
    required this.labelReader,
    required this.categoryReader,
  });

  factory UpdateEntry.build(DependencyContainer c) {
    return UpdateEntry(
      entryRepository: c.get<EntryRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      eventPublisher: c.get<DomainEventPublisher>(),
      journalReader: c.get<JournalReader>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
    );
  }

  Future<Entry> execute(
    String id, {
    String? note,
    required double amount,
    required EntryStatus status,
    required String journalId,
    required String categoryId,
    required Iterable<String> labelIds,
    required DateTime issuedAt,
  }) async {
    return unitOfWork.execute<Entry>(() async {
      final before = await entryRepository.get(id);
      if (before.readOnly) throw Exception();

      final journal = await journalReader.get(journalId);
      final category = await categoryReader.get(categoryId);
      final labels = await labelReader.getAll(labelIds);

      final after = before
          .copyWith(
            note: note,
            amount: amount,
            status: status,
            journalId: journalId,
            categoryId: categoryId,
          )
          .withJournal(journal)
          .withCategory(category)
          .withLabels(labels);

      await entryRepository.save(after);
      await eventPublisher.raise(EntryUpdated.of(before, after));

      return after;
    });
  }
}
