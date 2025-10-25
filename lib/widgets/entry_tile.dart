import 'package:banda/entity/entry.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/views/edit_entry_screen.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EntryTile extends StatelessWidget {
  final Entry entry;
  final dateFormatter = DateFormat("yyyy/MM/dd");

  EntryTile(this.entry, {super.key});

  String getDate() {
    return dateFormatter.format(entry.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      tileColor: entry.readonly ? theme.colorScheme.surfaceContainer : null,
      enableFeedback: !entry.readonly,
      enabled: !entry.readonly,
      onLongPress: !entry.readonly
          ? () {
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: const Text("Delete entry"),
                    content: const Text(
                      "Are you sure you want to remove this entry?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () {
                          final navigator = Navigator.of(context);
                          final entryProvider = context.read<EntryProvider>();

                          entryProvider.remove(entry.id).then((_) {
                            navigator.pop();
                          });
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            }
          : null,
      onTap: !entry.readonly
          ? () {
              final navigator = Navigator.of(context);
              context.read<EntryProvider>().get(entry.id).then((entry) {
                navigator.push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => EditEntryScreen(entry: entry),
                  ),
                );
              });
            }
          : null,
      title: Text(entry.categoryName, style: theme.textTheme.titleSmall),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "${entry.accountName} — ${entry.accountHolderName}",
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          Text(
            getDate(),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            entry.note,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      trailing: MoneyText(entry.amount),
    );
  }
}
