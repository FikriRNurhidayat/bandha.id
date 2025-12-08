import 'package:banda/entity/loan.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/helpers/type_helper.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoanTile extends StatelessWidget {
  final Loan loan;

  const LoanTile(this.loan, {super.key});

  String getIssueDate() {
    return DateHelper.formatSimpleDate(loan.issuedAt);
  }

  Widget getLoanStatusLabel(BuildContext context) {
    final theme = Theme.of(context);
    switch (loan.status) {
      case LoanStatus.active:
        return Icon(
          Icons.hourglass_empty,
          color: theme.colorScheme.primary,
          size: 8,
        );
      case LoanStatus.overdue:
        return Icon(
          Icons.hourglass_full,
          color: theme.colorScheme.primary,
          size: 8,
        );
      case LoanStatus.settled:
        return Icon(
          Icons.check,
          color: theme.colorScheme.primary,
          size: 8,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(loan.id),
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
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) {
        if (direction == DismissDirection.startToEnd) {
          return confirmLoanDeletion(context, loan);
        }

        Navigator.pushNamed(context, "/loans/${loan.id}/edit");
        return Future.value(false);
      },
      child: ListTile(
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(text: "app://bandha.id/loans/${loan.id}/detail"),
          );
        },
        onTap: () {
          Navigator.pushNamed(context, "/loans/${loan.id}/payments");
        },
        title: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(loan.type.label, style: theme.textTheme.titleSmall),
            Badge(
              label: getLoanStatusLabel(context),
              textColor: theme.colorScheme.onSurface,
              backgroundColor: Colors.transparent,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              getIssueDate(),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              loan.party.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MoneyText(loan.amount, useSymbol: false),
            if (!isZero(loan.fee))
              MoneyText(
                loan.fee!,
                useSymbol: false,
                style: theme.textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }
}
