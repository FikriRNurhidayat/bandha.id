import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/entries/domain/repositories/entry_repository.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';

class UpdateEntryParams {
  final String id;
  final String? note;
  final double amount;
  final EntryStatus status;
  final String journalId;
  final String categoryId;
  final Iterable<String> labelIds;
  final DateTime issuedAt;

  UpdateEntryParams(
    this.id, {
    this.note,
    required this.amount,
    required this.status,
    required this.journalId,
    required this.categoryId,
    required this.labelIds,
    required this.issuedAt,
  });
}

class UpdateEntry extends UseCase<UpdateEntryParams, Entry> {
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

  factory UpdateEntry.fromContainer(DependencyContainer c) {
    return UpdateEntry(
      entryRepository: c.get<EntryRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
      eventPublisher: c.get<DomainEventPublisher>(),
      journalReader: c.get<JournalReader>(),
      categoryReader: c.get<CategoryReader>(),
      labelReader: c.get<LabelReader>(),
    );
  }

  @override
  Future<Entry> execute(UpdateEntryParams params) async {
    return unitOfWork.execute<Entry>(() async {
      final before = await entryRepository.get(params.id);
      if (before.readOnly) throw Exception();

      final journal = await journalReader.get(params.journalId);
      final category = await categoryReader.get(params.categoryId);
      final labels = await labelReader.getAll(params.labelIds);

      final after = before
          .copyWith(
            note: params.note,
            amount: params.amount,
            status: params.status,
            journalId: params.journalId,
            categoryId: params.categoryId,
          )
          .withJournal(journal)
          .withCategory(category)
          .withLabels(labels);

      await entryRepository.save(after);

      eventPublisher.raise(EntryUpdated.of(before, after));

      return after;
    });
  }
}
