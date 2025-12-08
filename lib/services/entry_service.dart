import 'package:banda/entity/entry.dart';
import 'package:banda/managers/notification_manager.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/budget_repository.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/label_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/controller.dart';
import 'package:banda/types/notification_action.dart';
import 'package:banda/types/specification.dart';

class EntryService {
  final EntryRepository entryRepository;
  final AccountRepository accountRepository;
  final LabelRepository labelRepository;
  final BudgetRepository budgetRepository;
  final CategoryRepository categoryRepository;
  final NotificationManager notificationManager;

  const EntryService({
    required this.entryRepository,
    required this.accountRepository,
    required this.labelRepository,
    required this.budgetRepository,
    required this.categoryRepository,
    required this.notificationManager,
  });

  Future<void> snooze(String id) async {
    return Repository.work(() async {
      final entry = await entryRepository.withAccount().withLabels().get(id);
      await entryRepository.save(
        entry.copyWith(issuedAt: entry.issuedAt.add(Duration(days: 1))),
      );
    });
  }

  Future<void> markAsDone(String id) async {
    return Repository.work(() async {
      final entry = await entryRepository.withAccount().withLabels().get(id);
      await entryRepository.save(entry.copyWith(status: EntryStatus.done));
    });
  }

  delete(String id) {
    return Repository.work(() async {
      final entry = await entryRepository.withAccount().withLabels().get(id);

      if (entry.isExpense()) {
        final budget = await budgetRepository.getExactly(
          entry.categoryId,
          entry.issuedAt,
          entry.labels.map((label) => label.id).toList(),
        );

        if (budget != null) {
          await budgetRepository.save(budget.revokeEntry(entry));
        }
      }

      final account = entry.account.revokeEntry(entry);
      await entryRepository.delete(id);
      await accountRepository.save(account);
      await notificationManager.cancelReminder(Controller.entry(entry.id));
    });
  }

  get(String id) {
    return entryRepository.withLabels().withAccount().withCategory().get(id);
  }

  search({Specification? specification}) {
    return entryRepository.withLabels().withAccount().withCategory().search(
      specification,
    );
  }

  Future<Entry> create({
    required String note,
    required double amount,
    required EntryType type,
    required EntryStatus status,
    required String accountId,
    required String categoryId,
    required DateTime timestamp,
    List<String>? labelIds,
  }) {
    return Repository.work<Entry>(() async {
      final account = await accountRepository.get(accountId);
      final category = await categoryRepository.get(categoryId);

      final entry = Entry.writeable(
        note: note,
        amount: Entry.compute(type, amount),
        status: status,
        issuedAt: timestamp,
        categoryId: categoryId,
        accountId: accountId,
      );

      await entryRepository.save(entry);
      if (labelIds != null && labelIds.isNotEmpty) {
        await entryRepository.setLabels(entry.id, labelIds);
      }

      if (entry.isExpense()) {
        final budget = await budgetRepository.getExactly(
          categoryId,
          entry.issuedAt,
          labelIds,
        );

        if (budget != null) {
          await budgetRepository.save(budget.applyEntry(entry));
        }
      }

      await accountRepository.save(account.applyEntry(entry));

      if (entry.status.isPending()) {
        await notificationManager.setReminder(
          title: category.name,
          body:
              "Reminder: One of your ledger entries is still pending settlement.",
          sentAt: entry.issuedAt,
          controller: Controller.entry(entry.id),
          actions: [NotificationAction.markEntryAsDone],
        );
      }

      return entry;
    });
  }

  update({
    required String id,
    required String note,
    required double amount,
    required EntryType type,
    required EntryStatus status,
    required String accountId,
    required String categoryId,
    required DateTime timestamp,
    List<String>? labelIds,
  }) async {
    return Repository.work(() async {
      final entry = await entryRepository
          .withCategory()
          .withAccount()
          .withLabels()
          .get(id);

      await accountRepository.save(entry.account.revokeEntry(entry));

      if (entry.isExpense()) {
        final budget = await budgetRepository.getExactly(
          entry.categoryId,
          entry.issuedAt,
          entry.labels.map((label) => label.id).toList(),
        );

        if (budget != null) {
          await budgetRepository.save(budget.revokeEntry(entry));
        }
      }

      if (entry.status.isPending()) {
        notificationManager.cancelReminder(Controller.entry(entry.id));
      }

      final newEntry = entry.copyWith(
        note: note,
        amount: Entry.compute(type, amount),
        status: status,
        issuedAt: timestamp,
        categoryId: categoryId,
        accountId: accountId,
      );
      final newAccount = await accountRepository.get(accountId);
      final newCategory = await categoryRepository.get(categoryId);

      await entryRepository.save(newEntry);
      await accountRepository.save(newAccount.applyEntry(newEntry));

      if (newEntry.isExpense()) {
        final newBudget = await budgetRepository.getExactly(
          categoryId,
          newEntry.issuedAt,
          labelIds,
        );
        if (newBudget != null) {
          await budgetRepository.save(newBudget.applyEntry(newEntry));
        }
      }

      if (newEntry.status.isPending()) {
        notificationManager.setReminder(
          title: newCategory.name,
          body:
              "Reminder: One of your ledger entries is still pending settlement.",
          sentAt: newEntry.issuedAt,
          controller: Controller.entry(newEntry.id),
          actions: [NotificationAction.markEntryAsDone],
        );
      }
    });
  }

  debugReminder(String id) async {
    final entry = await entryRepository.withCategory().get(id);

    notificationManager.setReminder(
      title: entry.category.name,
      body: "Reminder: One of your ledger entries is still pending settlement.",
      sentAt: DateTime.now().add(Duration(seconds: 3)),
      controller: Controller.entry(entry.id),
      actions: [
        NotificationAction.markEntryAsDone,
        NotificationAction.snoozeEntry,
      ],
    );
  }
}
