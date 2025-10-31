import 'package:banda/entity/budget.dart';
import 'package:banda/providers/budget_provider.dart';
import 'package:banda/views/budget_edit_view.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetTile extends StatelessWidget {
  final Budget budget;

  const BudgetTile(this.budget, {super.key});

  Widget getBudgetStatusLabel(BuildContext context) {
    final theme = Theme.of(context);
    if (budget.isOver()) {
      return Icon(Icons.error, color: theme.colorScheme.primary, size: 8);
    }

    if (budget.isUnder()) {
      return Icon(
        Icons.hourglass_empty,
        color: theme.colorScheme.primary,
        size: 8,
      );
    }

    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(budget.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) {
        return showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Delete budget", style: theme.textTheme.titleMedium),
              alignment: Alignment.center,
              content: Text(
                "Are you sure you want to remove this budget?",
                style: theme.textTheme.bodySmall,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    final navigator = Navigator.of(ctx);
                    final messenger = ScaffoldMessenger.of(ctx);
                    final budgetProvider = ctx.read<BudgetProvider>();
                    try {
                      await budgetProvider.delete(budget.id);
                      navigator.pop(true);
                    } catch (error) {
                      messenger.showSnackBar(
                        SnackBar(content: Text("Delete budget failed")),
                      );
                      navigator.pop(false);
                    }
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      child: ListTile(
        dense: true,
        onTap: () {
          final navigator = Navigator.of(context);
          context.read<BudgetProvider>().get(budget.id).then((budget) {
            navigator.push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => BudgetEditView(budget: budget),
              ),
            );
          });
        },
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                spacing: 8,
                children: [
                  Text(budget.category.name, style: theme.textTheme.titleSmall),
                  getBudgetStatusLabel(context),
                ],
              ),
              Row(
                spacing: 8,
                children: [
                  Text(budget.cycle.label, style: theme.textTheme.labelSmall),
                  ...budget.labels
                      .take(2)
                      .map(
                        (label) => Badge(
                          label: Text(
                            label.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          textColor: theme.colorScheme.onSurface,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                  if (budget.labels.length > 2)
                    Badge(
                      label: Icon(
                        Icons.more_horiz_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      textColor: theme.colorScheme.onSurface,
                      backgroundColor: Colors.transparent,
                    ),
                ],
              ),
            ],
          ),
        ),
        subtitle: Column(
          spacing: 8,
          children: [
            SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: budget.getProgress(),
                backgroundColor: theme.colorScheme.surfaceContainer,
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (budget.usage > 0)
                  MoneyText(
                    budget.usage,
                    useSymbol: false,
                    style: theme.textTheme.labelSmall,
                  )
                else
                  SizedBox.shrink(),
                MoneyText(
                  budget.limit,
                  useSymbol: false,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
