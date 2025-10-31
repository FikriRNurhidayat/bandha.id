import 'package:banda/entity/entry.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/views/entry_edit_view.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EntryTile extends StatelessWidget {
  final Entry entry;
  final dateFormatter = DateFormat("yyyy/MM/dd");

  EntryTile(this.entry, {super.key});

  String getDate() {
    return DateHelper.formatSimpleDate(entry.issuedAt);
  }

  String getTime() {
    return DateHelper.formatTime(TimeOfDay.fromDateTime(entry.issuedAt));
  }

  Widget getEntryStatusLabel(BuildContext context) {
    final theme = Theme.of(context);
    switch (entry.status) {
      case EntryStatus.pending:
        return Icon(
          Icons.hourglass_empty,
          color: theme.colorScheme.primary,
          size: 8,
        );
      case EntryStatus.done:
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(entry.id),
      direction: entry.readonly
          ? DismissDirection.none
          : DismissDirection.startToEnd,
      confirmDismiss: (_) {
        return showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Delete entry", style: theme.textTheme.titleMedium),
              alignment: Alignment.center,
              content: Text(
                "Are you sure you want to remove this entry?",
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
                  onPressed: () {
                    final navigator = Navigator.of(ctx);
                    final messenger = ScaffoldMessenger.of(ctx);
                    final entryProvider = ctx.read<EntryProvider>();

                    entryProvider
                        .delete(entry.id)
                        .then((_) {
                          navigator.pop(true);
                        })
                        .catchError((_) {
                          messenger.showSnackBar(
                            SnackBar(content: Text("Delete entry failed")),
                          );
                          navigator.pop(false);
                        });
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
        enableFeedback: !entry.readonly,
        enabled: !entry.readonly,
        onTap: !entry.readonly
            ? () {
                final navigator = Navigator.of(context);
                context.read<EntryProvider>().get(entry.id).then((entry) {
                  navigator.push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => EntryEditView(entry: entry),
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
            Text(entry.category.name, style: theme.textTheme.titleSmall),
            if (entry.readonly)
              Icon(Icons.lock, size: 8, color: theme.colorScheme.primary),
            getEntryStatusLabel(context),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              entry.account.displayName(),
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
                ...entry.labels
                    .take(2)
                    .map(
                      (label) => Text(
                        label.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                if (entry.labels.length > 2)
                  Icon(
                    Icons.more_horiz,
                    size: 8,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ],
        ),
        trailing: MoneyText(entry.amount),
      ),
    );
  }
}
