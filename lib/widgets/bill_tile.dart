import 'package:banda/entity/bill.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BillTile extends StatelessWidget {
  final Bill bill;
  final dateFormatter = DateFormat("yyyy/MM/dd");

  BillTile(this.bill, {super.key});

  String getDate() {
    return DateHelper.formatSimpleDate(bill.billedAt);
  }

  String getTime() {
    return DateHelper.formatTime(TimeOfDay.fromDateTime(bill.billedAt));
  }

  Widget getBillStatusLabel(BuildContext context) {
    final theme = Theme.of(context);
    switch (bill.status) {
      case BillStatus.active:
        return Icon(
          Icons.hourglass_empty,
          color: theme.colorScheme.primary,
          size: 8,
        );
      case BillStatus.overdue:
        return Icon(Icons.warning, color: theme.colorScheme.primary, size: 8);
      case BillStatus.paid:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(bill.id),
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
          return confirmBillDeletion(context, bill);
        }

        Navigator.pushNamed(context, "/bills/${bill.id}/edit");
        return Future.value(false);
      },
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, "/bills/${bill.id}/detail");
        },
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(text: "app://bandha.id/bills/${bill.id}/detail"),
          );
        },
        dense: true,
        title: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(bill.category.name, style: theme.textTheme.titleSmall),
            getBillStatusLabel(context),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              bill.account.displayName(),
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
              bill.note,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              spacing: 8,
              children: [
                ...bill.labels
                    .take(2)
                    .map(
                      (label) => Text(
                        label.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                if (bill.labels.length > 2)
                  Icon(
                    Icons.more_horiz,
                    size: 8,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ],
        ),
        trailing: MoneyText(bill.amount, useSymbol: false),
      ),
    );
  }
}
