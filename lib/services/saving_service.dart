import 'package:banda/entity/entry.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/repositories/account_repository.dart';
import 'package:banda/repositories/category_repository.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/label_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/repositories/saving_repository.dart';
import 'package:banda/types/specification.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:flutter/foundation.dart';

@immutable
class SavingService {
  final SavingRepository savingRepository;
  final CategoryRepository categoryRepository;
  final EntryRepository entryRepository;
  final AccountRepository accountRepository;
  final LabelRepository labelRepository;

  const SavingService({
    required this.savingRepository,
    required this.categoryRepository,
    required this.entryRepository,
    required this.accountRepository,
    required this.labelRepository,
  });

  sync(String id) async {
    return await savingRepository.sync(id);
  }

  release(String id) async {
    return await Repository.work(() async {
      final now = DateTime.now();
      final category = await categoryRepository.getByName("Saving");
      final saving = await savingRepository.withAccount().get(id);
      await savingRepository.save(
        saving!.copyWith(releasedAt: now, status: SavingStatus.released),
      );

      final entry = Entry.create(
        note: "Released from ${saving.note}",
        amount: saving.balance,
        status: EntryStatus.done,
        issuedAt: now,
        readonly: true,
        accountId: saving.accountId,
        categoryId: category!.id,
      );

      await entryRepository.save(entry);
      await accountRepository.save(saving.account!.applyEntry(entry));
    });
  }

  create({
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    return await Repository.work(() async {
      final saving = Saving.create(
        note: note,
        goal: goal,
        balance: 0,
        accountId: accountId,
        status: SavingStatus.active,
      );

      await savingRepository.save(saving);
      if (labelIds != null) {
        await savingRepository.setLabels(saving.id, labelIds);
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
      final saving = await savingRepository.get(id);
      await savingRepository.save(saving!.copyWith(note: note, goal: goal));
      if (labelIds != null) {
        await savingRepository.setLabels(saving.id, labelIds);
      }
    });
  }

  delete(String id) async {
    return await Repository.work(() async {
      final saving = await savingRepository.withAccount().get(id);
      final account = saving!.account;

      await savingRepository.flushEntries(saving);
      await savingRepository.delete(saving.id);
      await accountRepository.sync(account!.id);
    });
  }

  search(Specification? specification) async {
    return await savingRepository.withLabels().withAccount().search(
      specification,
    );
  }

  get(String id) async {
    return await savingRepository.withLabels().withAccount().get(id);
  }

  searchEntries({required String savingId, Specification? specification}) {
    return entryRepository.search(
      specification: {
        "saving_in": [savingId],
        ...?specification,
      },
    );
  }

  createEntry({
    required String savingId,
    required TransactionType type,
    required double amount,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    return await Repository.work(() async {
      final category = await categoryRepository.getByName("Saving");
      final saving = await savingRepository.get(savingId);
      final account = await accountRepository.get(saving!.accountId);
      final isDeposit = type == TransactionType.deposit;

      final entry = Entry.create(
        note: isDeposit
            ? "Deposit to ${saving.note}"
            : "Withdraw from ${saving.note}",
        amount: amount * (isDeposit ? -1 : 1),
        status: EntryStatus.done,
        issuedAt: issuedAt,
        readonly: true,
        accountId: saving.accountId,
        categoryId: category!.id,
      );

      await entryRepository.save(entry);
      await accountRepository.save(account!.applyEntry(entry));
      await savingRepository.save(saving.applyEntry(entry));
      await savingRepository.addEntry(saving, entry);

      final entryLabelIds = <String>[];

      if (saving.labels != null) {
        entryLabelIds.addAll(saving.labels!.map((label) => label.id).toList());
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
    required String savingId,
    required String entryId,
    required TransactionType type,
    required double amount,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    return await Repository.work(() async {
      final isDeposit = type == TransactionType.deposit;
      final saving = await savingRepository.get(savingId);
      final account = await accountRepository.get(saving!.accountId);
      final entry = await entryRepository.get(entryId);

      final entryType = amount >= 0 ? EntryType.income : EntryType.expense;
      final entryAmount = amount * (isDeposit ? -1 : 1);
      final delta = entryAmount - entry!.amount;

      await entryRepository.save(
        entry.copyWith(amount: entryAmount, issuedAt: issuedAt),
      );

      await accountRepository.save(account!.applyDelta(entryType, delta));
      await savingRepository.save(saving.applyDelta(entryType, delta));

      final entryLabelIds = <String>[];
      if (saving.labels != null) {
        entryLabelIds.addAll(saving.labels!.map((label) => label.id).toList());
      }

      if (labelIds != null) {
        entryLabelIds.addAll(labelIds);
      }

      if (entryLabelIds.isNotEmpty) {
        await entryRepository.setLabels(entry.id, entryLabelIds);
      }
    });
  }

  deleteEntry({required String savingId, required String entryId}) async {
    return await Repository.work(() async {
      final saving = await savingRepository.get(savingId);
      final account = await accountRepository.get(saving!.accountId);
      final entry = await entryRepository.get(entryId);

      await accountRepository.save(account!.revokeEntry(entry!));
      await savingRepository.save(saving.revokeEntry(entry));
      await entryRepository.delete(entry.id);
    });
  }
}
