import 'package:banda/entity/entry.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/repositories/entry_repository.dart';
import 'package:banda/repositories/saving_repository.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:flutter/material.dart';

class SavingProvider extends ChangeNotifier {
  final EntryRepository entryRepository;
  final SavingRepository savingRepository;

  SavingProvider({
    required this.savingRepository,
    required this.entryRepository,
  });

  Future<List<Saving>> search(Map? spec) async {
    return savingRepository.search(spec);
  }

  Future<void> deleteEntry(Saving saving, String id) async {
    await savingRepository.deleteSavingEntry(saving, id);
    notifyListeners();
  }

  Future<void> updateEntry({
    required String id,
    required Saving saving,
    required double amount,
    required TransactionType type,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    await savingRepository.updateSavingEntry(
      id: id,
      saving: saving,
      amount: amount,
      type: type,
      issuedAt: issuedAt,
      labelIds: labelIds,
    );

    notifyListeners();
  }

  Future<void> createEntry({
    required Saving saving,
    required double amount,
    required TransactionType type,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    await savingRepository.createSavingEntry(
      saving: saving,
      amount: amount,
      type: type,
      issuedAt: issuedAt,
      labelIds: labelIds,
    );

    notifyListeners();
  }

  Future<List<Entry>> searchEntries(String id) async {
    return entryRepository.search(
      spec: {
        "saving_in": [id],
      },
    );
  }

  Future<void> add({
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    await savingRepository.create(
      note: note,
      goal: goal,
      accountId: accountId,
      labelIds: labelIds,
    );
    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    savingRepository.update(
      id: id,
      note: note,
      goal: goal,
      accountId: accountId,
      labelIds: labelIds,
    );
    notifyListeners();
  }

  Future<Saving?> get(String id) async {
    return savingRepository.get(id);
  }

  Future<void> remove(String id) async {
    await savingRepository.remove(id);
    notifyListeners();
  }

  Future<void> refresh(String id) async {
    await savingRepository.refresh(id);

    notifyListeners();
  }
}
