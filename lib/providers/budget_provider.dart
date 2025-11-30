import 'package:banda/entity/budget.dart';
import 'package:banda/services/budget_service.dart';
import 'package:banda/types/specification.dart';
import 'package:flutter/material.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService budgetService;
  BudgetProvider({required this.budgetService});

  Future<List<Budget>> search(Specification? spec) async {
    return budgetService.search(spec);
  }

  Future<void> create({
    required String note,
    required double threshold,
    required BudgetCycle cycle,
    required String categoryId,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    await budgetService.create(
      note: note,
      threshold: threshold,
      cycle: cycle,
      categoryId: categoryId,
      issuedAt: issuedAt,
      labelIds: labelIds,
    );

    notifyListeners();
  }

  Future<void> repeat(String id) async {
    await budgetService.repeat(id);

    notifyListeners();
  }

  Future<void> carryOver(String id) async {
    await budgetService.carryOver(id);

    notifyListeners();
  }

  Future<void> reset(String id) async {
    await budgetService.reset(id);

    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String note,
    required double threshold,
    required BudgetCycle cycle,
    required String categoryId,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) async {
    await budgetService.update(
      id: id,
      note: note,
      threshold: threshold,
      cycle: cycle,
      categoryId: categoryId,
      issuedAt: issuedAt,
      labelIds: labelIds,
    );

    notifyListeners();
  }

  Future<Budget> get(String id) async {
    return budgetService.get(id);
  }

  Future<void> delete(String id) async {
    await budgetService.delete(id);
    notifyListeners();
  }

  debugReminder(String id) {
    return budgetService.debugReminder(id);
  }
}
