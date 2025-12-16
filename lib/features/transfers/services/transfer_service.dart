import 'package:banda/common/entities/annotation.dart';
import 'package:banda/common/services/service.dart';
import 'package:banda/features/accounts/entities/account.dart';
import 'package:banda/features/entries/entities/entry.dart';
import 'package:banda/features/transfers/entities/transfer.dart';
import 'package:banda/features/transfers/repositories/transfer_repository.dart';
import 'package:banda/common/helpers/type_helper.dart';
import 'package:banda/features/accounts/repositories/account_repository.dart';
import 'package:banda/features/tags/repositories/category_repository.dart';
import 'package:banda/features/entries/repositories/entry_repository.dart';

class TransferService extends Service {
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;
  final EntryRepository entryRepository;
  final TransferRepository transferRepository;

  TransferService({
    required this.accountRepository,
    required this.categoryRepository,
    required this.entryRepository,
    required this.transferRepository,
  });

  Future<void> create({
    required double amount,
    required double? fee,
    required DateTime issuedAt,
    required String debitAccountId,
    required String creditAccountId,
  }) {
    return work(() async {
      final category = await categoryRepository.getByName("Transfer");
      final debitAccount = await accountRepository.get(debitAccountId);
      final creditAccount = await accountRepository.get(creditAccountId);

      final creditDraft = Entry.create(
        note: "Transfer to ${debitAccount.displayName()}",
        amount: amount * -1,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: creditAccount.id,
        categoryId: category.id,
      );

      final debitDraft = Entry.create(
        note: "Received from ${creditAccount.displayName()}",
        amount: amount,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: debitAccount.id,
        categoryId: category.id,
      );

      final exchangeDraft = !isZero(fee)
          ? Entry.create(
              note: "Exchange fee to ${debitAccount.displayName()}",
              amount: fee! * -1,
              status: EntryStatus.done,
              issuedAt: issuedAt,
              readonly: true,
              accountId: creditAccount.id,
              categoryId: category.id,
            ).annotate(Annotations.type, "fee")
          : null;

      final transfer = Transfer.create(
        note:
            "Transfer from ${creditAccount.displayName()} to ${debitAccount.displayName()}",
        amount: amount,
        fee: fee,
        debitId: debitDraft.id,
        debitAccountId: debitAccount.id,
        exchangeId: exchangeDraft?.id,
        creditId: creditDraft.id,
        creditAccountId: creditAccount.id,
        issuedAt: issuedAt,
      );

      final debit = debitDraft.controlledBy(transfer);
      final credit = creditDraft.controlledBy(transfer);
      final exchange = exchangeDraft?.controlledBy(transfer);

      await entryRepository.save(debit);
      await entryRepository.save(credit);
      if (!isNull(exchange)) await entryRepository.save(exchange);

      await transferRepository.save(transfer);

      await applyTransfer(
        debit: debitDraft,
        credit: creditDraft,
        exchange: exchange,
        debitAccount: debitAccount,
        creditAccount: creditAccount,
      );
    });
  }

  Future<void> update({
    required String id,
    required double amount,
    required double? fee,
    required DateTime issuedAt,
    required String debitAccountId,
    required String creditAccountId,
  }) {
    return work(() async {
      final transfer = await transferRepository
          .withEntries()
          .withAccounts()
          .get(id);

      await voidTransfer(
        debit: transfer.debit,
        credit: transfer.credit,
        exchange: transfer.exchange,
        debitAccount: transfer.debitAccount,
        creditAccount: transfer.creditAccount,
      );

      final debitAccount = await accountRepository.get(debitAccountId);
      final creditAccount = await accountRepository.get(creditAccountId);

      Entry? exchange;

      final credit = transfer.credit.copyWith(
        note: "Transfer to ${debitAccount.displayName()}",
        amount: amount * -1,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: creditAccount.id,
      );

      if (isZero(transfer.fee) && !isZero(fee)) {
        exchange = Entry.create(
          note: "Exchange fee to ${debitAccount.displayName()}",
          amount: fee! * -1,
          status: EntryStatus.done,
          issuedAt: issuedAt,
          readonly: true,
          accountId: creditAccount.id,
          categoryId: credit.categoryId,
        ).annotate(Annotations.type, "fee");
      }

      if (!isZero(transfer.fee) && !isZero(fee)) {
        exchange = transfer.exchange!
            .copyWith(
              note: "Exchange fee to ${debitAccount.displayName()}",
              amount: fee! * -1,
              status: EntryStatus.done,
              issuedAt: issuedAt,
              readonly: true,
              accountId: creditAccount.id,
              categoryId: credit.categoryId,
            )
            .annotate(Annotations.type, "fee");
      }

      final debit = transfer.debit.copyWith(
        note: "Received from ${creditAccount.displayName()}",
        amount: amount,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: debitAccount.id,
      );

      await transferRepository.save(
        transfer.copyWith(
          note:
              "Transfer from ${creditAccount.displayName()} to ${debitAccount.displayName()}",
          amount: amount,
          fee: fee,
          debitId: debit.id,
          debitAccountId: debitAccount.id,
          creditId: credit.id,
          creditAccountId: creditAccount.id,
          issuedAt: issuedAt,
        ),
      );

      await entryRepository.save(debit);
      await entryRepository.save(credit);
      if (!isNull(exchange)) await entryRepository.save(exchange!);

      await applyTransfer(
        debit: debit,
        credit: credit,
        exchange: exchange,
        debitAccount: debitAccount,
        creditAccount: creditAccount,
      );
    });
  }

  Future<void> delete(String id) {
    return work(() async {
      final transfer = await transferRepository
          .withEntries()
          .withAccounts()
          .get(id);

      await voidTransfer(
        debit: transfer.debit,
        credit: transfer.credit,
        exchange: transfer.exchange,
        debitAccount: transfer.debitAccount,
        creditAccount: transfer.creditAccount,
      );

      await entryRepository.delete(transfer.debit.id);
      await entryRepository.delete(transfer.credit.id);

      if (!isNull(transfer.exchange)) {
        await entryRepository.delete(transfer.exchange!.id);
      }

      await transferRepository.delete(transfer.id);
    });
  }

  Future<Transfer?> get(String id) {
    return transferRepository.withEntries().withAccounts().get(id);
  }

  Future<List<Transfer>> search() {
    return transferRepository.withEntries().withAccounts().search();
  }

  Future<void> voidTransfer({
    required Entry debit,
    required Entry credit,
    Entry? exchange,
    required Account debitAccount,
    required Account creditAccount,
  }) async {
    await accountRepository.save(debitAccount.revokeEntry(debit));
    await accountRepository.save(
      creditAccount.revokeEntries([credit, exchange]),
    );
  }

  Future<void> applyTransfer({
    required Entry debit,
    required Entry credit,
    Entry? exchange,
    required Account debitAccount,
    required Account creditAccount,
  }) async {
    await accountRepository.save(debitAccount.applyEntry(debit));
    await accountRepository.save(
      creditAccount.applyEntries([credit, exchange]),
    );
  }
}
