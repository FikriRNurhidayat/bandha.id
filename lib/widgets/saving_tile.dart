import 'package:banda/entity/saving.dart';
import 'package:banda/providers/saving_provider.dart';
import 'package:banda/views/view_saving_screen.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingTile extends StatelessWidget {
  final Saving saving;

  const SavingTile(this.saving, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        final navigator = Navigator.of(context);
        context.read<SavingProvider>().get(saving.id).then((entry) {
          navigator.push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => ViewSavingScreen(saving: saving),
            ),
          );
        });
      },
      onLongPress: saving.canDispense()
          ? () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete saving"),
                    content: const Text(
                      "Are you sure you want to remove this saving?",
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
                          final savingProvider = context.read<SavingProvider>();
                          await savingProvider.delete(saving.id);
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
                Text(saving.note, style: theme.textTheme.titleSmall),
                if (saving.status == SavingStatus.released)
                  Icon(Icons.lock, size: 8, color: theme.colorScheme.primary),
                if (saving.status != SavingStatus.released &&
                    saving.balance == saving.goal)
                  Icon(
                    Icons.done_all,
                    size: 8,
                    color: theme.colorScheme.primary,
                  ),
                if (saving.labels != null)
                  ...saving.labels!
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
                if ((saving.labels?.length ?? 0) > 2)
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
              saving.account!.displayName(),
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
              value: saving.getProgress(),
              backgroundColor: theme.colorScheme.surfaceContainer,
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MoneyText(
                saving.balance,
                useSymbol: false,
                style: theme.textTheme.labelSmall,
              ),
              MoneyText(
                saving.goal,
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
