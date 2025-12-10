import 'package:banda/entity/entry.dart';
import 'package:banda/entity/fund.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/types/transaction_type.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FundTransactionTile extends StatelessWidget {
  final Fund fund;
  final Entry entry;
  final dateFormatter = DateFormat("yyyy/MM/dd");

  FundTransactionTile(this.fund, this.entry, {super.key});

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
      direction: fund.canDispense()
          ? DismissDirection.horizontal
          : DismissDirection.none,
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) {
          return confirmFundTransactionDeletion(context, fund, entry);
        }

        Navigator.pushNamed(
          context,
          "/funds/${fund.id}/transactions/${entry.id}/edit",
        );

        return Future.value(false);
      },
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            "/funds/${fund.id}/transactions/${entry.id}/detail",
          );
        },
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(
              text:
                  "app://bandha.id/funds/${fund.id}/transactions/${entry.id}/detail",
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
                          style: theme.textTheme.bodySmall,
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [MoneyText(entry.amount * -1)],
        ),
      ),
    );
  }
}
