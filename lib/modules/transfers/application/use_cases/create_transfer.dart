import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class CreateTransfer {
  final EntryWriter entryWriter;
  final LabelReader labelReader;
  final TransferRepository transferRepository;
  final UnitOfWork unitOfWork;

  CreateTransfer({
    required this.entryWriter,
    required this.labelReader,
    required this.unitOfWork,
    required this.transferRepository,
  });

  factory CreateTransfer.build(DependencyContainer c) {
    return CreateTransfer(
      entryWriter: c.get<EntryWriter>(),
      labelReader: c.get<LabelReader>(),
      unitOfWork: c.get<UnitOfWork>(),
      transferRepository: c.get<TransferRepository>(),
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
      final labels = await labelReader.getAll([
        SystemLabels.fee,
        SystemLabels.credit,
        SystemLabels.debit,
      ]);

      final debitLabel = labels.firstWhere(
        (label) => label.id == SystemLabels.debit,
      );
      final creditLabel = labels.firstWhere(
        (label) => label.id == SystemLabels.credit,
      );
      final feeLabel = labels.firstWhere(
        (label) => label.id == SystemLabels.fee,
      );

      final credit = entryWriter
          .readOnly(
            journalId: creditJournalId,
            amount: creditAmount,
            issuedAt: issuedAt,
          )
          .withLabels([creditLabel]);

      final creditFee = creditFeeAmount != null
          ? entryWriter
                .readOnly(
                  journalId: creditJournalId,
                  amount: creditFeeAmount,
                  issuedAt: issuedAt,
                )
                .withLabels([creditLabel, feeLabel])
          : null;

      final debit = entryWriter
          .readOnly(
            journalId: debitJournalId,
            amount: debitAmount,
            issuedAt: issuedAt,
          )
          .withLabels([debitLabel]);

      final debitFee = debitFeeAmount != null
          ? entryWriter
                .readOnly(
                  journalId: debitJournalId,
                  amount: debitFeeAmount,
                  issuedAt: issuedAt,
                )
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
