import 'package:banda/entity/entry.dart';
import 'package:banda/services/entry_service.dart';
import 'package:flutter/material.dart';

class EntryProvider extends ChangeNotifier {
  final EntryService entryService;

  EntryProvider(this.entryService);

  Future<List<Entry>> search({Spec? spec}) async {
    return entryService.search(spec: spec);
  }

  Future<Entry?> get(String id) async {
    return entryService.get(id);
  }

  Future<void> create({
    required String note,
    required double amount,
    required EntryType type,
    required EntryStatus status,
    required DateTime timestamp,
    required String accountId,
    required String categoryId,
    List<String>? labelIds,
  }) async {
    await entryService.create(
      note: note,
      amount: amount,
      type: type,
      status: status,
      timestamp: timestamp,
      accountId: accountId,
      categoryId: categoryId,
      labelIds: labelIds,
    );
    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String note,
    required double amount,
    required EntryType type,
    required EntryStatus status,
    required DateTime timestamp,
    required String accountId,
    required String categoryId,
    List<String>? labelIds,
  }) async {
    await entryService.update(
      id: id,
      note: note,
      amount: amount,
      type: type,
      status: status,
      timestamp: timestamp,
      accountId: accountId,
      categoryId: categoryId,
      labelIds: labelIds,
    );
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await entryService.delete(id);
    notifyListeners();
  }
}
