import 'package:banda/entity/account.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/entity/transfer.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/repositories/transfer_repository.dart';
import 'package:banda/types/specification.dart';

class TransferService {
  final AccountRepository accountRepository;
  final CategoryRepository categoryRepository;
  final EntryRepository entryRepository;
  final TransferRepository transferRepository;

  const TransferService({
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
  }) async {
    return await Repository.work(() async {
      final category = await categoryRepository.getByName("Transfer");
      final debitAccount = await accountRepository.get(debitAccountId);
      final creditAccount = await accountRepository.get(creditAccountId);

      final credit = Entry.create(
        note: "Transfer to ${debitAccount!.displayName()}",
        amount: (amount + (fee ?? 0)) * -1,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: creditAccount!.id,
        categoryId: category!.id,
      );

      final debit = Entry.create(
        note: "Received from ${creditAccount.displayName()}",
        amount: amount,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: debitAccount.id,
        categoryId: category.id,
      );

      final transfer = Transfer.create(
        note:
            "Transfer from ${creditAccount.displayName()} to ${debitAccount.displayName()}",
        amount: amount,
        fee: fee,
        debitId: debit.id,
        debitAccountId: debitAccount.id,
        creditId: credit.id,
        creditAccountId: creditAccount.id,
        issuedAt: issuedAt,
      );

      await entryRepository.save(debit);
      await entryRepository.save(credit);
      await transferRepository.save(transfer);

      await applyTransfer(
        debit: debit,
        credit: credit,
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
  }) async {
    return await Repository.work(() async {
      final transfer = await transferRepository
          .withEntries()
          .withAccounts()
          .get(id);

      await voidTransfer(
        debit: transfer!.debit!,
        credit: transfer.credit!,
        debitAccount: transfer.debitAccount!,
        creditAccount: transfer.creditAccount!,
      );

      final debitAccount = await accountRepository.get(debitAccountId);
      final creditAccount = await accountRepository.get(creditAccountId);

      final credit = transfer.credit!.copyWith(
        note: "Transfer to ${debitAccount!.displayName()}",
        amount: (amount + (fee ?? 0)) * -1,
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: creditAccount!.id,
      );

      final debit = transfer.debit!.copyWith(
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

      await applyTransfer(
        debit: debit,
        credit: credit,
        debitAccount: debitAccount,
        creditAccount: creditAccount,
      );
    });
  }

  Future<void> delete(String id) async {
    return await Repository.work(() async {
      final transfer = await transferRepository.get(id);
      final debit = transfer!.debit!;
      final credit = transfer.credit!;
      final debitAccount = transfer.debitAccount!;
      final creditAccount = transfer.creditAccount!;

      await voidTransfer(
        debit: debit,
        credit: credit,
        debitAccount: debitAccount,
        creditAccount: creditAccount,
      );

      await entryRepository.delete(debit.id);
      await entryRepository.delete(credit.id);
      await transferRepository.delete(transfer.id);
    });
  }

  Future<Transfer?> get(String id) {
    return transferRepository.withEntries().withAccounts().get(id);
  }

  Future<List<Transfer>> search({Specification? spec}) {
    return transferRepository.withEntries().withAccounts().search();
  }

  Future<void> voidTransfer({
    required Entry debit,
    required Entry credit,
    required Account debitAccount,
    required Account creditAccount,
  }) async {
    await accountRepository.save(debitAccount.revokeEntry(debit));
    await accountRepository.save(creditAccount.revokeEntry(credit));
  }

  Future<void> applyTransfer({
    required Entry debit,
    required Entry credit,
    required Account debitAccount,
    required Account creditAccount,
  }) async {
    await accountRepository.save(debitAccount.applyEntry(debit));
    await accountRepository.save(creditAccount.applyEntry(credit));
  }
}
