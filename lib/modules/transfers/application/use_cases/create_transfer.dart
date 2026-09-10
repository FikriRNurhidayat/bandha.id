import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/constants/system_categories.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/journals/domain/ports/journal_reader.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class CreateTransfer {
  final EntryWriter entryWriter;
  final LabelReader labelReader;
  final CategoryReader categoryReader;
  final JournalReader journalReader;
  final TransferRepository transferRepository;
  final UnitOfWork unitOfWork;

  CreateTransfer({
    required this.entryWriter,
    required this.labelReader,
    required this.unitOfWork,
    required this.transferRepository,
    required this.journalReader,
    required this.categoryReader,
  });

  factory CreateTransfer.build(DependencyContainer c) {
    return CreateTransfer(
      entryWriter: c.get<EntryWriter>(),
      labelReader: c.get<LabelReader>(),
      categoryReader: c.get<CategoryReader>(),
      unitOfWork: c.get<UnitOfWork>(),
      transferRepository: c.get<TransferRepository>(),
      journalReader: c.get<JournalReader>(),
    );
  }

  Future<Transfer> execute({
    String? note,
    required String debitJournalId,
    required String creditJournalId,
    required double debitAmount,
    required double creditAmount,
    double? debitFeeAmount,
    double? creditFeeAmount,
    required DateTime issuedAt,
  }) async {
    return unitOfWork.execute(() async {
      final category = await categoryReader.get(SystemCategories.transferId);

      final labels = await labelReader.getAll([
        SystemLabels.feeId,
        SystemLabels.creditId,
        SystemLabels.debitId,
      ]);

      final journals = await journalReader.getAll([
        creditJournalId,
        debitJournalId,
      ]);

      final debitLabel = labels.firstWhere(
        (label) => label.id == SystemLabels.debitId,
      );
      final creditLabel = labels.firstWhere(
        (label) => label.id == SystemLabels.creditId,
      );
      final feeLabel = labels.firstWhere(
        (label) => label.id == SystemLabels.feeId,
      );
      final creditJournal = journals.firstWhere(
        (journal) => journal.id == creditJournalId,
      );
      final debitJournal = journals.firstWhere(
        (journal) => journal.id == debitJournalId,
      );

      final credit = entryWriter
          .readOnly(
            categoryId: category.id,
            journalId: creditJournalId,
            amount: creditAmount,
            issuedAt: issuedAt,
          )
          .withCategory(category)
          .withJournal(creditJournal)
          .withLabels([creditLabel]);

      final creditFee = creditFeeAmount != null
          ? entryWriter
                .readOnly(
                  categoryId: category.id,
                  journalId: creditJournalId,
                  amount: creditFeeAmount,
                  issuedAt: issuedAt,
                )
                .withCategory(category)
                .withJournal(creditJournal)
                .withLabels([creditLabel, feeLabel])
          : null;

      final debit = entryWriter
          .readOnly(
            categoryId: category.id,
            journalId: debitJournalId,
            amount: debitAmount,
            issuedAt: issuedAt,
          )
          .withCategory(category)
          .withJournal(debitJournal)
          .withLabels([debitLabel]);

      final debitFee = debitFeeAmount != null
          ? entryWriter
                .readOnly(
                  categoryId: category.id,
                  journalId: debitJournalId,
                  amount: debitFeeAmount,
                  issuedAt: issuedAt,
                )
                .withCategory(category)
                .withJournal(debitJournal)
                .withLabels([debitLabel, feeLabel])
          : null;

      final entries = [debit, debitFee, credit, creditFee].whereType<Entry>();

      final transfer = Transfer.create(
        creditId: credit.id,
        creditFeeId: creditFee?.id,
        debitId: debit.id,
        debitFeeId: debitFee?.id,
        issuedAt: issuedAt,
      );

      await entryWriter.createAll(entries.map((entry) => entry.of(transfer)));
      await transferRepository.save(transfer);

      return transfer;
    });
  }
}
