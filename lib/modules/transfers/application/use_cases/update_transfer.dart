import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/types/data_change.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/domain/ports/entry_writer.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/domain/repositories/transfer_repository.dart';

class UpdateTransfer {
  final EntryWriter entryWriter;
  final TransferRepository transferRepository;
  final UnitOfWork unitOfWork;

  UpdateTransfer({
    required this.entryWriter,
    required this.unitOfWork,
    required this.transferRepository,
  });

  factory UpdateTransfer.build(DependencyContainer c) {
    return UpdateTransfer(
      entryWriter: c.get<EntryWriter>(),
      unitOfWork: c.get<UnitOfWork>(),
      transferRepository: c.get<TransferRepository>(),
    );
  }

  Future<Transfer> execute(
    String id, {
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
      final transfer = await transferRepository.get(id);
      final change = DataChange<Transfer>(
        transfer,
        transfer.copyWith(note: note, issuedAt: issuedAt),
      );

      final changeSet = entryWriter.plan();

      await _updateDebit(note, debitJournalId, debitAmount, issuedAt, change, changeSet);
      await _updateDebitFee(note, debitJournalId, debitFeeAmount, issuedAt, change, changeSet);
      await _updateCredit(note, creditJournalId, creditAmount, issuedAt, change, changeSet);
      await _updateCreditFee(note, creditJournalId, creditFeeAmount, issuedAt, change, changeSet);

      await entryWriter.execute(changeSet);
      await transferRepository.save(change.after);

      return change.after;
    });
  }

  Future<void> _updateDebit(
    String? note,
    String debitJournalId,
    double debitAmount,
    DateTime issuedAt,
    DataChange<Transfer> change,
    DataChangeSet<Entry> changeSet,
  ) async {
    if (!_debitChanged(change.before, debitAmount, debitJournalId)) return;

    change.after.withDebit(
      changeSet.update(
        change.before.debit,
        change.before.debit.copyWith(
          journalId: debitJournalId,
          amount: debitAmount,
          note: note,
          issuedAt: issuedAt,
        ),
      ),
    );
  }

  Future<void> _updateCredit(
    String? note,
    String creditJournalId,
    double creditAmount,
    DateTime issuedAt,
    DataChange<Transfer> change,
    DataChangeSet<Entry> changeSet,
  ) async {
    if (!_creditChanged(change.before, creditAmount, creditJournalId)) return;

    change.after.withCredit(
      changeSet.update(
        change.before.credit,
        change.before.credit.copyWith(
          journalId: creditJournalId,
          amount: creditAmount,
          note: note,
          issuedAt: issuedAt,
        ),
      ),
    );
  }

  Future<void> _updateDebitFee(
    String? note,
    String debitJournalId,
    double? debitFeeAmount,
    DateTime issuedAt,
    DataChange<Transfer> change,
    DataChangeSet<Entry> changeSet,
  ) async {
    if (_debitFeeRemoved(debitFeeAmount) && change.before.debitFee != null) {
      changeSet.destroy(change.before.debitFee!);
      change.after.clearDebitFee();
      return;
    }

    if (!_debitFeeChanged(change.before, debitFeeAmount)) return;

    final feeAmount = debitFeeAmount!;

    if (change.before.debitFee == null) {
      change.after.withDebitFee(
        changeSet.create(
          entryWriter.readOnly(
            journalId: debitJournalId,
            amount: feeAmount,
            note: note,
            issuedAt: issuedAt,
          ),
        ),
      );

      return;
    }

    change.after.withDebitFee(
      changeSet.update(
        change.before.debitFee!,
        change.before.debitFee!.copyWith(
          journalId: debitJournalId,
          amount: feeAmount,
          note: note,
          issuedAt: issuedAt,
        ),
      ),
    );
  }

  Future<void> _updateCreditFee(
    String? note,
    String creditJournalId,
    double? creditFeeAmount,
    DateTime issuedAt,
    DataChange<Transfer> change,
    DataChangeSet<Entry> changeSet,
  ) async {
    if (_creditFeeRemoved(creditFeeAmount) && change.before.creditFee != null) {
      changeSet.destroy(change.before.creditFee!);
      change.after.clearCreditFee();
      return;
    }

    if (!_creditFeeChanged(change.before, creditFeeAmount)) return;

    final feeAmount = creditFeeAmount!;

    if (change.before.creditFee == null) {
      change.after.withCreditFee(
        changeSet.create(
          entryWriter.readOnly(
            journalId: creditJournalId,
            amount: feeAmount,
            note: note,
            issuedAt: issuedAt,
          ),
        ),
      );

      return;
    }

    change.after.withCreditFee(
      changeSet.update(
        change.before.creditFee!,
        change.before.creditFee!.copyWith(
          journalId: creditJournalId,
          amount: feeAmount,
          note: note,
          issuedAt: issuedAt,
        ),
      ),
    );
  }

  bool _debitFeeRemoved(double? debitFeeAmount) {
    return debitFeeAmount == null || debitFeeAmount == 0;
  }

  bool _debitFeeChanged(Transfer transfer, double? debitFeeAmount) {
    return transfer.debitFee == null
        ? debitFeeAmount != null
        : transfer.debitFee!.amount != debitFeeAmount;
  }

  bool _debitChanged(Transfer transfer, double debitAmount, String debitJournalId) {
    return transfer.debit.amount != debitAmount ||
        transfer.debit.journalId != debitJournalId;
  }

  bool _creditFeeRemoved(double? creditFeeAmount) {
    return creditFeeAmount == null || creditFeeAmount == 0;
  }

  bool _creditFeeChanged(Transfer transfer, double? creditFeeAmount) {
    return transfer.creditFee == null
        ? creditFeeAmount != null
        : transfer.creditFee!.amount != creditFeeAmount;
  }

  bool _creditChanged(Transfer transfer, double creditAmount, String creditJournalId) {
    return transfer.credit.amount != creditAmount ||
        transfer.credit.journalId != creditJournalId;
  }
}
