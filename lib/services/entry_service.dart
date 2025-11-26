import 'package:banda/entity/entry.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/budget_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/label_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/specification.dart';

class EntryService {
  final EntryRepository entryRepository;
  final AccountRepository accountRepository;
  final LabelRepository labelRepository;
  final BudgetRepository budgetRepository;

  const EntryService({
    required this.entryRepository,
    required this.accountRepository,
    required this.labelRepository,
    required this.budgetRepository,
  });

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

  create({
    required String note,
    required double amount,
    required EntryType type,
    required EntryStatus status,
    required String accountId,
    required String categoryId,
    required DateTime timestamp,
    List<String>? labelIds,
  }) {
    return Repository.work(() async {
      final account = await accountRepository.get(accountId);

      final entry = Entry.forUser(
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
      final entry = await entryRepository.withAccount().withLabels().get(id);

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

      final newEntry = entry.copyWith(
        note: note,
        amount: Entry.compute(type, amount),
        status: status,
        issuedAt: timestamp,
        categoryId: categoryId,
        accountId: accountId,
      );
      final newAccount = await accountRepository.get(accountId);
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
    });
  }
}
