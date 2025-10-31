import 'package:banda/entity/bill.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/bill_repository.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/specification.dart';

class BillService {
  final AccountRepository accountRepository;
  final BillRepository billRepository;
  final CategoryRepository categoryRepository;
  final EntryRepository entryRepository;

  const BillService({
    required this.accountRepository,
    required this.billRepository,
    required this.categoryRepository,
    required this.entryRepository,
  });

  search(Specification specification) {
    return billRepository
        .withAccount()
        .withLabels()
        .withCategory()
        .withLabels()
        .search(specification);
  }

  get(String id) {
    return billRepository
        .withAccount()
        .withLabels()
        .withCategory()
        .withLabels()
        .get(id);
  }

  delete(String id) {
    return Repository.work(() async {
      final bill = await billRepository.withAccount().withEntry().get(id);
      await accountRepository.save(bill.account.revokeEntry(bill.entry));
      await billRepository.delete(bill.id);
      await entryRepository.delete(bill.entryId);
    });
  }

  create({
    required String note,
    required double amount,
    required BillCycle cycle,
    required BillStatus status,
    required String categoryId,
    required String accountId,
    required DateTime billedAt,
    List<String>? labelIds,
  }) {
    return Repository.work(() async {
      final account = await accountRepository.get(accountId);

      final entry = Entry.bySystem(
        note: note,
        amount: amount * -1,
        status: status.entryStatus,
        issuedAt: billedAt,
        accountId: accountId,
        categoryId: categoryId,
      );

      final bill = Bill.create(
        note: note,
        amount: amount,
        cycle: cycle,
        status: status,
        categoryId: categoryId,
        accountId: accountId,
        entryId: entry.id,
        billedAt: billedAt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await accountRepository.save(account.applyEntry(entry));
      await billRepository.save(bill);

      if (labelIds != null) {
        await billRepository.setLabels(bill.id, labelIds);
        await entryRepository.setLabels(entry.id, labelIds);
      }
    });
  }

  update({
    required String id,
    required String note,
    required double amount,
    required BillCycle cycle,
    required BillStatus status,
    required String categoryId,
    required String accountId,
    required DateTime billedAt,
    List<String>? labelIds,
  }) {
    return Repository.work(() async {
      final bill = await billRepository.withEntry().withAccount().get(id);

      await accountRepository.save(bill.account.revokeEntry(bill.entry));

      final newBill = bill.copyWith(
        note: note,
        amount: amount,
        cycle: cycle,
        status: status,
        categoryId: categoryId,
        accountId: accountId,
        billedAt: billedAt,
        updatedAt: DateTime.now(),
      );

      final newEntry = bill.entry.copyWith(
        note: note,
        amount: amount * -1,
        issuedAt: billedAt,
        categoryId: categoryId,
        accountId: accountId,
        updatedAt: DateTime.now(),
      );

      final newAccount = await accountRepository.get(accountId);

      await billRepository.save(newBill);
      await entryRepository.save(newEntry);
      await accountRepository.save(newAccount.applyEntry(newEntry));

      if (labelIds != null) {
        await billRepository.setLabels(newBill.id, labelIds);
        await entryRepository.setLabels(newEntry.id, labelIds);
      }
    });
  }
}
