import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class UpdateTransferParams {
  final String id;
  final String? note;
  final String debitJournalId;
  final String creditJournalId;
  final double debitAmount;
  final double creditAmount;
  final double? debitFeeAmount;
  final double? creditFeeAmount;
  final DateTime issuedAt;

  UpdateTransferParams(
    this.id, {
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

class UpdateTransfer extends UseCase<UpdateTransferParams, Transfer> {
  final EntryWriter entryWriter;
  final TransferRepository transferRepository;
  final UnitOfWork unitOfWork;

  UpdateTransfer({
    required this.entryWriter,
    required this.unitOfWork,
    required this.transferRepository,
  });

  factory UpdateTransfer.fromContainer(DependencyContainer c) {
    return UpdateTransfer(
      entryWriter: c.get<EntryWriter>(),
      unitOfWork: c.get<UnitOfWork>(),
      transferRepository: c.get<TransferRepository>(),
    );
  }

  @override
  Future<Transfer> execute(UpdateTransferParams params) async {
    return unitOfWork.execute(() async {
      final transfer = await transferRepository.get(params.id);
      final change = DataChange<Transfer>(
        transfer,
        transfer.copyWith(note: params.note, issuedAt: params.issuedAt),
      );

      final changeSet = entryWriter.plan();

      await updateDebit(params, change, changeSet);
      await updateDebitFee(params, change, changeSet);
      await updateCredit(params, change, changeSet);
      await updateCreditFee(params, change, changeSet);

      await entryWriter.execute(changeSet);
      await transferRepository.save(change.after);

      return change.after;
    });
  }

  Future<void> updateDebit(
    UpdateTransferParams params,
    DataChange<Transfer> change,
    DataChangeSet<Entry> changeSet,
  ) async {
    if (!params.debitChanged(change.before)) return;

    change.after.withDebit(
      changeSet.update(
        change.before.debit,
        change.before.debit.copyWith(
          journalId: params.debitJournalId,
          amount: params.debitAmount,
          note: params.note,
          issuedAt: params.issuedAt,
        ),
      ),
    );
  }

  Future<void> updateCredit(
    UpdateTransferParams params,
    DataChange<Transfer> change,
    DataChangeSet<Entry> changeSet,
  ) async {
    if (!params.creditChanged(change.before)) return;

    change.after.withCredit(
      changeSet.update(
        change.before.credit,
        change.before.credit.copyWith(
          journalId: params.creditJournalId,
          amount: params.creditAmount,
          note: params.note,
          issuedAt: params.issuedAt,
        ),
      ),
    );
  }

  Future<void> updateDebitFee(
    UpdateTransferParams params,
    DataChange<Transfer> change,
    DataChangeSet<Entry> changeSet,
  ) async {
    if (params.debitFeeRemoved && change.before.debitFee != null) {
      changeSet.destroy(change.before.debitFee!);
      change.after.clearDebitFee();
      return;
    }

    if (!params.debitFeeChanged(change.before)) return;

    final feeAmount = params.debitFeeAmount!;

    if (change.before.debitFee == null) {
      change.after.withDebitFee(
        changeSet.create(
          entryWriter.readOnly(
            journalId: params.debitJournalId,
            amount: feeAmount,
            note: params.note,
            issuedAt: params.issuedAt,
          ),
        ),
      );

      return;
    }

    change.after.withDebitFee(
      changeSet.update(
        change.before.debitFee!,
        change.before.debitFee!.copyWith(
          journalId: params.debitJournalId,
          amount: feeAmount,
          note: params.note,
          issuedAt: params.issuedAt,
        ),
      ),
    );
  }

  Future<void> updateCreditFee(
    UpdateTransferParams params,
    DataChange<Transfer> change,
    DataChangeSet<Entry> changeSet,
  ) async {
    if (params.creditFeeRemoved && change.before.creditFee != null) {
      changeSet.destroy(change.before.creditFee!);
      change.after.clearCreditFee();
      return;
    }

    if (!params.creditFeeChanged(change.before)) return;

    final feeAmount = params.creditFeeAmount!;

    if (change.before.creditFee == null) {
      change.after.withCreditFee(
        changeSet.create(
          entryWriter.readOnly(
            journalId: params.creditJournalId,
            amount: feeAmount,
            note: params.note,
            issuedAt: params.issuedAt,
          ),
        ),
      );

      return;
    }

    change.after.withCreditFee(
      changeSet.update(
        change.before.creditFee!,
        change.before.creditFee!.copyWith(
          journalId: params.creditJournalId,
          amount: feeAmount,
          note: params.note,
          issuedAt: params.issuedAt,
        ),
      ),
    );
  }
}

extension UpdateTransferParamsExtension on UpdateTransferParams {
  bool get debitFeeRemoved {
    return debitFeeAmount == null || debitFeeAmount == 0;
  }

  bool debitFeeChanged(Transfer transfer) {
    return transfer.debitFee == null
        ? debitFeeAmount != null
        : transfer.debitFee!.amount != debitFeeAmount;
  }

  bool debitChanged(Transfer transfer) {
    return transfer.debit.amount != debitAmount ||
        transfer.debit.journalId != debitJournalId;
  }

  bool get creditFeeRemoved {
    return creditFeeAmount == null || creditFeeAmount == 0;
  }

  bool creditFeeChanged(Transfer transfer) {
    return transfer.creditFee == null
        ? creditFeeAmount != null
        : transfer.creditFee!.amount != creditFeeAmount;
  }

  bool creditChanged(Transfer transfer) {
    return transfer.credit.amount != creditAmount ||
        transfer.credit.journalId != creditJournalId;
  }
}
