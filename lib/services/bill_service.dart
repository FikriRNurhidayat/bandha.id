import 'package:banda/entity/bill.dart';
import 'package:banda/entity/entry.dart';
import 'package:banda/managers/notification_manager.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/bill_repository.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/controller.dart';
import 'package:banda/types/controller_type.dart';
import 'package:banda/types/specification.dart';

class BillService {
  final AccountRepository accountRepository;
  final BillRepository billRepository;
  final CategoryRepository categoryRepository;
  final EntryRepository entryRepository;
  final NotificationManager notificationManager;

  const BillService({
    required this.accountRepository,
    required this.billRepository,
    required this.categoryRepository,
    required this.entryRepository,
    required this.notificationManager,
  });

  search(Specification? specification) {
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

      final entry = Entry.readOnly(
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

      final billEntry = entry.controlledBy(bill);

      await entryRepository.save(billEntry);
      await accountRepository.save(account.applyEntry(billEntry));
      await billRepository.save(bill);

      if (labelIds != null) {
        await billRepository.setLabels(bill.id, labelIds);
        await entryRepository.setLabels(entry.id, labelIds);
      }

      if (!bill.status.isPaid()) {
        await notificationManager.setReminder(
          title: "Bill",
          body: "${bill.note} is due",
          sentAt: billEntry.issuedAt,
          controller: Controller.bill(bill.id),
        );
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

      if (!bill.status.isPaid()) {
        await notificationManager.cancelReminder(Controller.bill(bill.id));
      }

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

      if (!newBill.status.isPaid()) {
        await notificationManager.setReminder(
          title: "Bill",
          body: "${newBill.note} is due",
          sentAt: newEntry.issuedAt,
          controller: Controller.bill(newBill.id),
        );
      }
    });
  }

  debugReminder(String id) async {
    final bill = await billRepository.withAccount().get(id);
    await notificationManager.setReminder(
      title: "Bill",
      body: "${bill.note} is due",
      sentAt: DateTime.now().add(Duration(seconds: 3)),
      controller: Controller.bill(bill.id),
    );
  }
}
