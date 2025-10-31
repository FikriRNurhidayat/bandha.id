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
    required double limit,
    required BudgetCycle cycle,
    required String categoryId,
    DateTime? expiredAt,
    List<String>? labelIds,
  }) async {
    await budgetService.create(
      note: note,
      limit: limit,
      cycle: cycle,
      categoryId: categoryId,
      expiredAt: expiredAt,
      labelIds: labelIds,
    );

    notifyListeners();
  }

  Future<void> update({
    required String id,
    required String note,
    required double limit,
    required BudgetCycle cycle,
    required String categoryId,
    DateTime? expiredAt,
    List<String>? labelIds,
  }) async {
    await budgetService.update(
      id: id,
      note: note,
      limit: limit,
      cycle: cycle,
      categoryId: categoryId,
      expiredAt: expiredAt,
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
}
