import 'package:banda/common/services/service.dart';
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
            ).annotate("type", "fee")
          : null;

      var transfer = Transfer.create(
        note: "Transfer from ${creditAccount.displayName()} to ${debitAccount.displayName()}",
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

      transfer = transfer
          .withCredit(credit)
          .withDebit(debit)
          .withCreditAccount(creditAccount)
          .withDebitAccount(debitAccount)
          .withExchange(exchange);

      await entryRepository.withAnnotations().bulkSave(transfer.entries);
      await transferRepository.save(transfer);
      await executeTransfer(transfer);
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
      var transfer = await transferRepository.withEntries().withAccounts().get(id);

      await abortTransfer(transfer);

      final debitAccount = await accountRepository.get(debitAccountId);
      final creditAccount = await accountRepository.get(creditAccountId);

      final credit = transfer.credit.copyWith(
        note: "Transfer to ${debitAccount.displayName()}",
        amount: amount * -1,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: creditAccount.id,
      );

      final exchangeId = transfer.exchangeId;
      final exchangeRemoved = !isZero(transfer.fee) && isZero(fee);
      final Entry? exchange = !isZero(fee)
          ? (transfer.hasExchange
                    ? transfer.exchange!.copyWith(
                        note: "Exchange fee to ${debitAccount.displayName()}",
                        amount: fee! * -1,
                        status: EntryStatus.done,
                        issuedAt: issuedAt,
                        readonly: true,
                        accountId: creditAccount.id,
                        categoryId: credit.categoryId,
                      )
                    : Entry.create(
                        note: "Exchange fee to ${debitAccount.displayName()}",
                        amount: fee! * -1,
                        status: EntryStatus.done,
                        issuedAt: issuedAt,
                        readonly: true,
                        accountId: creditAccount.id,
                        categoryId: credit.categoryId,
                      ))
                .annotate("type", "fee")
          : null;

      final debit = transfer.debit.copyWith(
        note: "Received from ${creditAccount.displayName()}",
        amount: amount,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: debitAccount.id,
      );

      transfer = transfer
          .copyWith(
            note:
                "Transfer from ${creditAccount.displayName()} to ${debitAccount.displayName()}",
            amount: amount,
            fee: fee,
            debitId: debit.id,
            debitAccountId: debitAccount.id,
            creditId: credit.id,
            creditAccountId: creditAccount.id,
            issuedAt: issuedAt,
          )
          .withExchangeId(exchange?.id)
          .withExchange(exchange)
          .withDebit(debit)
          .withCredit(credit)
          .withDebitAccount(debitAccount)
          .withCreditAccount(creditAccount);

      await transferRepository.save(transfer);
      await entryRepository.withAnnotations().bulkSave(transfer.entries);
      await executeTransfer(transfer);
      if (exchangeRemoved) {
        await entryRepository.delete(exchangeId!);
      }
    });
  }

  Future<void> delete(String id) {
    return work(() async {
      final transfer = await transferRepository.withEntries().withAccounts().get(id);
      await abortTransfer(transfer);
      await transferRepository.delete(transfer.id);
      await entryRepository.deleteByIds(transfer.entryIds);
    });
  }

  Future<Transfer?> get(String id) {
    return transferRepository.withEntries().withAccounts().get(id);
  }

  Future<List<Transfer>> search() {
    return transferRepository.withEntries().withAccounts().search();
  }

  Future<void> abortTransfer(Transfer transfer) async {
    await accountRepository.bulkSave([
      transfer.debitAccount.revokeEntry(transfer.debit),
      transfer.creditAccount.revokeEntries(transfer.credits),
    ]);
  }

  Future<void> executeTransfer(Transfer transfer) async {
    await accountRepository.bulkSave([
      transfer.debitAccount.applyEntry(transfer.debit),
      transfer.creditAccount.applyEntries(transfer.credits),
    ]);
  }
}
