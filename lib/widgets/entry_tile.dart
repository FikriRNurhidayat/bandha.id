import 'package:banda/entity/entry.dart';
import 'package:banda/helpers/date_helper.dart';
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
    return DateHelper.formatSimpleDate(entry.timestamp);
  }

  String getTime() {
    return DateHelper.formatTime(TimeOfDay.fromDateTime(entry.timestamp));
  }

  Widget getEntryStatusLabel(BuildContext context) {
    final theme = Theme.of(context);
    switch (entry.status) {
      case EntryStatus.pending:
        return Icon(Icons.incomplete_circle, color: theme.colorScheme.primary, size: 8);
      case EntryStatus.done:
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
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
      title: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(entry.categoryName, style: theme.textTheme.titleSmall),
          if (entry.readonly)
            Icon(Icons.lock_outline, size: 8, color: theme.colorScheme.primary),
          getEntryStatusLabel(context),
        ],
      ),
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
            "${getDate()} at ${getTime()}",
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
          Row(
            spacing: 8,
            children: [
              if (entry.labels != null)
                ...entry.labels!
                    .take(2)
                    .map(
                      (label) => Badge(
                        padding: EdgeInsets.all(0.0),
                        label: Text(
                          label.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        textColor: theme.colorScheme.onSurface,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
              if ((entry.labels?.length ?? 0) > 2)
                Badge(
                  padding: EdgeInsets.all(0),
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
      trailing: MoneyText(entry.amount),
    );
  }
}
