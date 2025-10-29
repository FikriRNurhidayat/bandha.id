import 'package:banda/entity/entry.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/providers/saving_provider.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:banda/views/edit_saving_entry_screen.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SavingEntryTile extends StatelessWidget {
  final Saving saving;
  final Entry entry;
  final dateFormatter = DateFormat("yyyy/MM/dd");

  SavingEntryTile(this.saving, this.entry, {super.key});

  String getDate() {
    return DateHelper.formatSimpleDate(entry.issuedAt);
  }

  String getTime() {
    return DateHelper.formatTime(TimeOfDay.fromDateTime(entry.issuedAt));
  }

  String getTransactionType() {
    return entry.amount >= 0
        ? TransactionType.withdrawal.label
        : TransactionType.deposit.label;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      onLongPress: saving.canDispense()
          ? () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete saving entry"),
                    content: const Text(
                      "Are you sure you want to remove this saving entry?",
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
                          final savingProvider = context.read<SavingProvider>();

                          savingProvider
                              .deleteEntry(
                                savingId: saving.id,
                                entryId: entry.id,
                              )
                              .then((_) {
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
      onTap: saving.canDispense()
          ? () {
              final navigator = Navigator.of(context);
              context.read<EntryProvider>().get(entry.id).then((entry) {
                navigator.push(
                  MaterialPageRoute(
                    builder: (_) =>
                        EditSavingEntryScreen(saving: saving, entry: entry),
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
          Text(getTransactionType(), style: theme.textTheme.titleSmall),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "${getDate()} at ${getTime()}",
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
                        padding: EdgeInsets.all(0),
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
      trailing: MoneyText(entry.amount * -1),
    );
  }
}
