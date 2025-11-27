import 'package:banda/entity/entry.dart';
import 'package:banda/entity/savings.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/label_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/repositories/savings_repository.dart';
import 'package:banda/types/controller_type.dart';
import 'package:banda/types/specification.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:flutter/foundation.dart';

@immutable
class SavingsService {
  final SavingsRepository savingsRepository;
  final CategoryRepository categoryRepository;
  final EntryRepository entryRepository;
  final AccountRepository accountRepository;
  final LabelRepository labelRepository;

  const SavingsService({
    required this.savingsRepository,
    required this.categoryRepository,
    required this.entryRepository,
    required this.accountRepository,
    required this.labelRepository,
  });

  sync(String id) {
    return savingsRepository.sync(id);
  }

  release(String id) {
    return Repository.work(() async {
      final now = DateTime.now();
      final category = await categoryRepository.getByName("Saving");
      final savings = await savingsRepository.withAccount().get(id);
      await savingsRepository.save(
        savings.copyWith(releasedAt: now, status: SavingsStatus.released),
      );

      final entry = Entry.create(
        note: "Released from ${savings.note}",
        amount: savings.balance,
        status: EntryStatus.done,
        issuedAt: now,
        readonly: true,
        accountId: savings.accountId,
        categoryId: category.id,
      );

      await entryRepository.save(
        entry.withController(ControllerType.savings, savings.id),
      );
      await accountRepository.save(savings.account.applyEntry(entry));
    });
  }

  create({
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    return await Repository.work(() async {
      final savings = Savings.create(
        note: note,
        goal: goal,
        balance: 0,
        accountId: accountId,
        status: SavingsStatus.active,
      );

      await savingsRepository.save(savings);
      if (labelIds != null) {
        await savingsRepository.setLabels(savings.id, labelIds);
      }
    });
  }

  update({
    required String id,
    required String note,
    required double goal,
    List<String>? labelIds,
  }) async {
    return await Repository.work(() async {
      final savings = await savingsRepository.get(id);
      await savingsRepository.save(savings.copyWith(note: note, goal: goal));
      if (labelIds != null) {
        await savingsRepository.setLabels(savings.id, labelIds);
      }
    });
  }

  delete(String id) {
    return Repository.work(() async {
      final savings = await savingsRepository.withAccount().get(id);
      final account = savings.account;
      await savingsRepository.removeEntries(savings);
      await savingsRepository.delete(savings.id);
      await accountRepository.sync(account.id);
    });
  }

  search(Specification? specification) {
    return savingsRepository.withLabels().withAccount().search(specification);
  }

  get(String id) {
    return savingsRepository.withLabels().withAccount().get(id);
  }

  searchEntries({required String savingsId, Specification? specification}) {
    return entryRepository.withLabels().withAccount().search({
      "savings_in": [savingsId],
      ...?specification,
    });
  }

  createEntry({
    required String savingsId,
    required TransactionType type,
    required double amount,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    return await Repository.work(() async {
      final category = await categoryRepository.getByName("Saving");
      final savings = await savingsRepository.withLabels().withAccount().get(
        savingsId,
      );
      final isDeposit = type == TransactionType.deposit;

      final entry = Entry.create(
        note: isDeposit
            ? "Deposit to ${savings.note}"
            : "Withdraw from ${savings.note}",
        amount: amount * (isDeposit ? -1 : 1),
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: savings.accountId,
        categoryId: category.id,
      );

      await entryRepository.save(
        entry.withController(ControllerType.savings, savings.id),
      );
      await accountRepository.save(savings.account.applyEntry(entry));
      await savingsRepository.save(savings.applyEntry(entry));
      await savingsRepository.addEntry(savings, entry);

      final entryLabelIds = <String>[];

      if (savings.labels.isNotEmpty) {
        entryLabelIds.addAll(savings.labels.map((label) => label.id).toList());
      }

      if (labelIds != null) {
        entryLabelIds.addAll(labelIds);
      }

      if (entryLabelIds.isNotEmpty) {
        await entryRepository.setLabels(entry.id, entryLabelIds);
      }
    });
  }

  updateEntry({
    required String savingsId,
    required String entryId,
    required TransactionType type,
    required double amount,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    return await Repository.work(() async {
      final isDeposit = type == TransactionType.deposit;
      final savings = await savingsRepository.withAccount().withLabels().get(
        savingsId,
      );
      final entry = await entryRepository.get(entryId);
      await accountRepository.save(savings.account.revokeEntry(entry));
      await savingsRepository.save(savings.revokeEntry(entry));

      final newEntry = entry.copyWith(
        amount: amount * (isDeposit ? -1 : 1),
        issuedAt: issuedAt,
      );

      await entryRepository.save(newEntry);
      await accountRepository.save(savings.account.applyEntry(newEntry));
      await savingsRepository.save(savings.applyEntry(newEntry));

      final entryLabelIds = <String>[];
      if (savings.labels.isNotEmpty) {
        entryLabelIds.addAll(savings.labels.map((label) => label.id).toList());
      }

      if (labelIds != null) {
        entryLabelIds.addAll(labelIds);
      }

      if (entryLabelIds.isNotEmpty) {
        await entryRepository.setLabels(newEntry.id, entryLabelIds);
      }
    });
  }

  deleteEntry({required String savingsId, required String entryId}) async {
    return await Repository.work(() async {
      final savings = await savingsRepository.withAccount().get(savingsId);
      final entry = await entryRepository.get(entryId);

      await accountRepository.save(savings.account.revokeEntry(entry));
      await savingsRepository.save(savings.revokeEntry(entry));
      await entryRepository.delete(entry.id);
    });
  }
}
