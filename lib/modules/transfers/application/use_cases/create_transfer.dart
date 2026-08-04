import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/constants/system_labels.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class CreateTransferParams {
  final String? note;
  final String debitJournalId;
  final String creditJournalId;
  final double debitAmount;
  final double creditAmount;
  final double? debitFeeAmount;
  final double? creditFeeAmount;
  final DateTime issuedAt;

  CreateTransferParams({
    this.note,
    required this.debitJournalId,
    required this.creditJournalId,
    required this.debitAmount,
    required this.creditAmount,
    this.debitFeeAmount,
    this.creditFeeAmount,
    required this.issuedAt,
  });
}

class CreateTransfer extends UseCase<CreateTransferParams, Transfer> {
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

  factory CreateTransfer.fromContainer(DependencyContainer c) {
    return CreateTransfer(
      entryWriter: c.get<EntryWriter>(),
      labelReader: c.get<LabelReader>(),
      unitOfWork: c.get<UnitOfWork>(),
      transferRepository: c.get<TransferRepository>(),
    );
  }

  @override
  Future<Transfer> execute(CreateTransferParams params) async {
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
            journalId: params.creditJournalId,
            amount: params.creditAmount,
            issuedAt: params.issuedAt,
          )
          .withLabels([creditLabel]);

      final creditFee = params.creditFeeAmount != null
          ? entryWriter
                .readOnly(
                  journalId: params.creditJournalId,
                  amount: params.creditFeeAmount!,
                  issuedAt: params.issuedAt,
                )
                .withLabels([creditLabel, feeLabel])
          : null;

      final debit = entryWriter
          .readOnly(
            journalId: params.debitJournalId,
            amount: params.debitAmount,
            issuedAt: params.issuedAt,
          )
          .withLabels([debitLabel]);

      final debitFee = params.debitFeeAmount != null
          ? entryWriter
                .readOnly(
                  journalId: params.debitJournalId,
                  amount: params.debitFeeAmount!,
                  issuedAt: params.issuedAt,
                )
                .withLabels([debitLabel, feeLabel])
          : null;

      final entries = [debit, debitFee, credit, creditFee].whereType<Entry>();

      final transfer = Transfer.create(
        creditId: credit.id,
        creditFeeId: creditFee?.id,
        debitId: debit.id,
        debitFeeId: debitFee?.id,
        issuedAt: params.issuedAt,
      );

      await entryWriter.createAll(entries.map((entry) => entry.of(transfer)));
      await transferRepository.save(transfer);

      return transfer;
    });
  }
}
