import 'package:banda/entity/fund.dart';
import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/helpers/money_helper.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FundTile extends StatelessWidget {
  final Fund fund;

  const FundTile(this.fund, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(fund.id),
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
          : DismissDirection.endToStart,
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) {
          return confirmFundDeletion(context, fund);
        }

        Navigator.pushNamed(context, "/funds/${fund.id}/edit");
        return Future.value(false);
      },
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, "/funds/${fund.id}/transactions");
        },
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(text: "app://bandha.id/funds/${fund.id}/detail"),
          );
        },
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Text(fund.note, style: theme.textTheme.titleSmall),
                if (fund.status == FundStatus.released)
                  Icon(Icons.lock, size: 8, color: theme.colorScheme.primary),
                if (fund.status != FundStatus.released &&
                    fund.balance == fund.goal)
                  Icon(
                    Icons.done_all,
                    size: 8,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
            Text(fund.account.displayName(), style: theme.textTheme.bodySmall),
            Row(
              spacing: 8,
              children: [
                ...fund.labels
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
                if (fund.labels.length > 2)
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Text(
                  MoneyHelper.normalize(fund.balance),
                  style: theme.textTheme.bodyLarge,
                ),
                Text("/", style: theme.textTheme.bodySmall),
                Text(
                  MoneyHelper.normalize(fund.goal),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            Badge(
              padding: EdgeInsets.all(0),
              label: Text(fund.status.label, style: theme.textTheme.bodySmall),
              textColor: theme.colorScheme.onSurface,
              backgroundColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
