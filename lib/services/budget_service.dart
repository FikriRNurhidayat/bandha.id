import 'package:banda/entity/budget.dart';
import 'package:banda/repositories/budget_repository.dart';
import 'package:banda/repositories/repository.dart';
import 'package:banda/types/specification.dart';

class BudgetService {
  final BudgetRepository budgetRepository;
  const BudgetService({required this.budgetRepository});

  create({
    required String note,
    required double limit,
    required BudgetCycle cycle,
    required String categoryId,
    DateTime? expiredAt,
    List<String>? labelIds,
  }) {
    return Repository.work(() async {
      final budget = Budget.create(
        note: note,
        usage: 0,
        limit: limit,
        cycle: cycle,
        categoryId: categoryId,
        expiredAt: expiredAt,
      );

      await budgetRepository.save(budget);
      if (labelIds != null) {
        await budgetRepository.setLabels(budget.id, labelIds);
      }
    });
  }

  update({
    required String id,
    required String note,
    required double limit,
    required BudgetCycle cycle,
    required String categoryId,
    DateTime? expiredAt,
    List<String>? labelIds,
  }) {
    return Repository.work(() async {
      final budget = await budgetRepository.get(id);

      await budgetRepository.save(
        budget.copyWith(
          note: note,
          limit: limit,
          cycle: cycle,
          categoryId: categoryId,
          expiredAt: expiredAt,
          updatedAt: DateTime.now(),
        ),
      );

      if (labelIds != null) {
        await budgetRepository.setLabels(budget.id, labelIds);
      }
    });
  }

  delete(String id) {
    return budgetRepository.delete(id);
  }

  get(String id) {
    return budgetRepository.withLabels().withCategory().get(id);
  }

  search(Specification? specification) {
    return budgetRepository.withLabels().withCategory().search(specification);
  }
}
