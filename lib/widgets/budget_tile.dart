import 'package:banda/entity/budget.dart';
import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/providers/budget_provider.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BudgetTile extends StatelessWidget {
  final Budget budget;

  const BudgetTile(this.budget, {super.key});

  Widget getBudgetStatusLabel(BuildContext context) {
    final theme = Theme.of(context);
    if (budget.isOver()) {
      return Icon(
        Icons.error_outline_outlined,
        color: theme.colorScheme.primary,
        size: 8,
      );
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
      direction: DismissDirection.horizontal,
      background: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      secondaryBackground: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) {
          return confirmBudgetDeletion(context, budget);
        }

        Navigator.pushNamed(context, "budgets/${budget.id}/edit");
        return Future.value(false);
      },
      child: ListTile(
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(text: "app://bandha.id/budgets/${budget.id}/detail"),
          );
        },
        dense: true,
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
