import 'package:banda/entity/entry.dart';
import 'package:banda/entity/savings.dart';
import 'package:banda/services/savings_service.dart';
import 'package:banda/types/specification.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:flutter/material.dart';

class SavingsProvider extends ChangeNotifier {
  final SavingsService savingsService;

  SavingsProvider({required this.savingsService});

  Future<List<Savings>> search(Specification? specification) async {
    return await savingsService.search(specification);
  }

  Future<void> deleteEntry({
    required String savingsId,
    required String entryId,
  }) async {
    await savingsService.deleteEntry(savingsId: savingsId, entryId: entryId);

    notifyListeners();
  }

  Future<void> updateEntry({
    required String entryId,
    required String savingsId,
    required double amount,
    required TransactionType type,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    await savingsService.updateEntry(
      savingsId: savingsId,
      entryId: entryId,
      amount: amount,
      type: type,
      issuedAt: issuedAt,
    );

    notifyListeners();
  }

  Future<void> createEntry({
    required String savingsId,
    required double amount,
    required TransactionType type,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    await savingsService.createEntry(
      savingsId: savingsId,
      amount: amount,
      type: type,
      issuedAt: issuedAt,
    );

    notifyListeners();
  }

  Future<List<Entry>> searchEntries({
    required String savingsId,
    Specification? specification,
  }) async {
    return await savingsService.searchEntries(
      savingsId: savingsId,
      specification: specification,
    );
  }

  Future<void> create({
    required String note,
    required double goal,
    required String accountId,
    List<String>? labelIds,
  }) async {
    await savingsService.create(
      note: note,
      goal: goal,
      accountId: accountId,
      labelIds: labelIds,
    );

    notifyListeners();
  }

  Future<void> release(String id) async {
    await savingsService.release(id);
    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String note,
    required double goal,
    List<String>? labelIds,
  }) async {
    await savingsService.update(
      id: id,
      note: note,
      goal: goal,
      labelIds: labelIds,
    );

    notifyListeners();
  }

  Future<Savings?> get(String id) async {
    return await savingsService.get(id);
  }

  Future<void> delete(String id) async {
    await savingsService.delete(id);
    notifyListeners();
  }

  Future<void> sync(String id) async {
    return await savingsService.sync(id);
  }
}
