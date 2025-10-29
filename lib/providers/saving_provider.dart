import 'package:banda/entity/entry.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/services/saving_service.dart';
import 'package:banda/types/specification.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:flutter/material.dart';

class SavingProvider extends ChangeNotifier {
  final SavingService savingService;

  SavingProvider({required this.savingService});

  Future<List<Saving>> search(Specification? specification) async {
    return await savingService.search(specification);
  }

  Future<void> deleteEntry({
    required String savingId,
    required String entryId,
  }) async {
    await savingService.deleteEntry(savingId: savingId, entryId: entryId);

    notifyListeners();
  }

  Future<void> updateEntry({
    required String entryId,
    required String savingId,
    required double amount,
    required TransactionType type,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    await savingService.updateEntry(
      savingId: savingId,
      entryId: entryId,
      amount: amount,
      type: type,
      issuedAt: issuedAt,
    );

    notifyListeners();
  }

  Future<void> createEntry({
    required String savingId,
    required double amount,
    required TransactionType type,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    await savingService.createEntry(
      savingId: savingId,
      amount: amount,
      type: type,
      issuedAt: issuedAt,
    );

    notifyListeners();
  }

  Future<List<Entry>> searchEntries({
    required String savingId,
    Specification? specification,
  }) async {
    return await savingService.searchEntries(
      savingId: savingId,
      specification: specification,
    );
  }

  Future<void> create({
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    await savingService.create(
      note: note,
      goal: goal,
      accountId: accountId,
      labelIds: labelIds,
    );

    notifyListeners();
  }

  Future<void> release(String id) async {
    await savingService.release(id);
    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String note,
    required double goal,
    List<String>? labelIds,
  }) async {
    await savingService.update(
      id: id,
      note: note,
      goal: goal,
      labelIds: labelIds,
    );

    notifyListeners();
  }

  Future<Saving?> get(String id) async {
    return await savingService.get(id);
  }

  Future<void> delete(String id) async {
    await savingService.delete(id);
    notifyListeners();
  }

  Future<void> sync(String id) async {
    return await savingService.sync(id);
  }
}
