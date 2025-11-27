import 'package:banda/entity/entry.dart';
import 'package:banda/entity/savings.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/savings_provider.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SavingEntryTile extends StatelessWidget {
  final Savings savings;
  final Entry entry;
  final dateFormatter = DateFormat("yyyy/MM/dd");

  SavingEntryTile(this.savings, this.entry, {super.key});

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

    return Dismissible(
      key: Key(entry.id),
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
      direction: savings.canDispense()
          ? DismissDirection.horizontal
          : DismissDirection.none,
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) {
          return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Delete savings entry"),
                content: const Text(
                  "Are you sure you want to remove this savings entry?",
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
                      final savingsProvider = context.read<SavingsProvider>();

                      savingsProvider
                          .deleteEntry(savingsId: savings.id, entryId: entry.id)
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

        Navigator.pushNamed(
          context,
          "/savings/${savings.id}/entries/${entry.id}/edit",
        );

        return Future.value(false);
      },
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            "/savings/${savings.id}/entries/${entry.id}/detail",
          );
        },
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(
              text:
                  "app://banda.io/savings/${savings.id}/entries/${entry.id}/detail",
            ),
          );
        },
        dense: true,
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
                ...entry.labels
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
                if (entry.labels.length > 2)
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
      ),
    );
  }
}
