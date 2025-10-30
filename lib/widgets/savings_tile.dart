import 'package:banda/entity/savings.dart';
import 'package:banda/providers/savings_provider.dart';
import 'package:banda/views/view_savings_view.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingTile extends StatelessWidget {
  final Savings savings;

  const SavingTile(this.savings, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        final navigator = Navigator.of(context);
        context.read<SavingsProvider>().get(savings.id).then((entry) {
          navigator.push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => ViewSavingView(savings: savings),
            ),
          );
        });
      },
      onLongPress: savings.canDispense()
          ? () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete savings"),
                    content: const Text(
                      "Are you sure you want to remove this savings?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final savingsProvider = context
                              .read<SavingsProvider>();
                          await savingsProvider.delete(savings.id);
                          navigator.pop();
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            }
          : null,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                Text(savings.note, style: theme.textTheme.titleSmall),
                if (savings.status == SavingsStatus.released)
                  Icon(Icons.lock, size: 8, color: theme.colorScheme.primary),
                if (savings.status != SavingsStatus.released &&
                    savings.balance == savings.goal)
                  Icon(
                    Icons.done_all,
                    size: 8,
                    color: theme.colorScheme.primary,
                  ),
                if (savings.labels != null)
                  ...savings.labels!
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
                if ((savings.labels?.length ?? 0) > 2)
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
            Text(
              savings.account!.displayName(),
              style: theme.textTheme.labelSmall,
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
              value: savings.getProgress(),
              backgroundColor: theme.colorScheme.surfaceContainer,
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (savings.balance > 0)
                MoneyText(
                  savings.balance,
                  useSymbol: false,
                  style: theme.textTheme.labelSmall,
                )
              else
                SizedBox.shrink(),
              MoneyText(
                savings.goal,
                useSymbol: false,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
