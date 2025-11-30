import 'package:banda/entity/bill.dart';
import 'package:banda/services/bill_service.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

class BillProvider extends ChangeNotifier {
  final BillService billService;

  BillProvider({required this.billService});

  Future<List<Bill>> search(Specification? spec) async {
    return billService.search(spec);
  }

  Future<void> create({
    required String note,
    required double amount,
    required BillCycle cycle,
    required BillStatus status,
    required String categoryId,
    required String accountId,
    required DateTime billedAt,
    List<String>? labelIds,
  }) async {
    await billService.create(
      note: note,
      amount: amount,
      cycle: cycle,
      status: status,
      categoryId: categoryId,
      accountId: accountId,
      billedAt: billedAt,
    );

    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String note,
    required double amount,
    required BillCycle cycle,
    required BillStatus status,
    required String categoryId,
    required String accountId,
    required DateTime billedAt,
    List<String>? labelIds,
  }) async {
    await billService.update(
      id: id,
      note: note,
      amount: amount,
      cycle: cycle,
      status: status,
      categoryId: categoryId,
      accountId: accountId,
      billedAt: billedAt,
    );

    notifyListeners();
  }

  Future<Bill?> get(String id) async {
    return billService.get(id);
  }

  Future<void> delete(String id) async {
    await billService.delete(id);
    notifyListeners();
  }

  debugReminder(String id) {
    return billService.debugReminder(id);
  }
}
