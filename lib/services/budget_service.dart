import 'package:banda/common/services/service.dart';
import 'package:banda/entity/budget.dart';
import 'package:banda/managers/notification_manager.dart';
import 'package:banda/repositories/budget_repository.dart';
import 'package:banda/types/controller.dart';
import 'package:banda/types/specification.dart';

class BudgetService extends Service {
  final BudgetRepository budgetRepository;
  final NotificationManager notificationManager;

  BudgetService({
    required this.budgetRepository,
    required this.notificationManager,
  });

  Future<Budget> create({
    required String note,
    required double threshold,
    required BudgetCycle cycle,
    required String categoryId,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) {
    return work<Budget>(() async {
      final budget = Budget.create(
        note: note,
        usage: 0,
        threshold: threshold,
        limit: threshold,
        cycle: cycle,
        categoryId: categoryId,
        issuedAt: issuedAt,
        startAt: cycle.start(issuedAt),
        endAt: cycle.end(issuedAt),
      );

      await budgetRepository.save(budget);
      if (labelIds != null) {
        await budgetRepository.setLabels(budget.id, labelIds);
      }

      if (budget.cycle.isDefinite()) {
        await notificationManager.setReminder(
          title: budget.note,
          body: "Reminder: Recap budget.",
          sentAt: budget.endAt!,
          controller: Controller.budget(budget.id),
        );
      }

      return budget;
    });
  }

  update({
    required String id,
    required String note,
    required double threshold,
    required BudgetCycle cycle,
    required String categoryId,
    required DateTime issuedAt,
    List<String>? labelIds,
  }) {
    return work(() async {
      final budget = await budgetRepository.get(id);

      final limit = budget.threshold != threshold ? threshold : budget.limit;

      final newBudget = budget.copyWith(
        note: note,
        threshold: threshold,
        limit: limit,
        cycle: cycle,
        categoryId: categoryId,
        issuedAt: issuedAt,
        startAt: cycle.start(issuedAt),
        endAt: cycle.end(issuedAt),
        updatedAt: DateTime.now(),
      );

      if (budget.cycle.isDefinite()) {
        await notificationManager.cancelReminder(Controller.budget(budget.id));
      }

      await budgetRepository.save(newBudget);

      if (labelIds != null) {
        await budgetRepository.setLabels(newBudget.id, labelIds);
      }

      if (newBudget.cycle.isDefinite()) {
        await notificationManager.setReminder(
          title: budget.note,
          body: "Reminder: Recap budget.",
          sentAt: budget.endAt!,
          controller: Controller.budget(budget.id),
        );
      }
    });
  }

  carryOver(String id) async {
    return work(() async {
      final budget = await budgetRepository.get(id);
      await budgetRepository.save(
        budget.copyWith(
          usage: 0,
          limit: budget.limit + budget.remainder,
          startAt: budget.endAt,
          endAt: budget.cycle.end(budget.endAt!),
        ),
      );
    });
  }

  repeat(String id) async {
    return work(() async {
      final budget = await budgetRepository.get(id);
      await budgetRepository.save(
        budget.copyWith(
          usage: 0,
          limit: budget.limit,
          startAt: budget.endAt,
          endAt: budget.cycle.end(budget.endAt!),
        ),
      );
    });
  }

  reset(String id) async {
    return work(() async {
      final budget = await budgetRepository.get(id);
      await budgetRepository.save(
        budget.copyWith(
          usage: 0,
          limit: budget.threshold,
          startAt: budget.endAt,
          endAt: budget.cycle.end(budget.endAt!),
        ),
      );
    });
  }

  delete(String id) {
    return work(() async {
      final budget = await budgetRepository.get(id);
      await budgetRepository.delete(budget.id);

      if (budget.cycle.isDefinite()) {
        await notificationManager.cancelReminder(Controller.budget(budget.id));
      }
    });
  }

  get(String id) {
    return budgetRepository.withLabels().withCategory().get(id);
  }

  debugReminder(String id) async {
    final budget = await budgetRepository.get(id);
    await notificationManager.setReminder(
      title: budget.note,
      body: "Reminder: Recap budget.",
      sentAt: DateTime.now().add(Duration(seconds: 3)),
      controller: Controller.budget(budget.id),
    );
  }

  search(Filter? specification) {
    return budgetRepository.withLabels().withCategory().search(specification);
  }
}
