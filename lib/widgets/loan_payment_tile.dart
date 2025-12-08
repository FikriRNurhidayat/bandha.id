import 'package:banda/entity/entry.dart';
import 'package:banda/entity/loan.dart';
import 'package:banda/entity/loan_payment.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class LoanPaymentTile extends StatelessWidget {
  final Loan loan;
  final LoanPayment payment;
  final dateFormatter = DateFormat("yyyy/MM/dd");

  LoanPaymentTile({super.key, required this.payment, required this.loan});

  String getDate() {
    return DateHelper.formatSimpleDate(payment.issuedAt);
  }

  String getTime() {
    return DateHelper.formatTime(TimeOfDay.fromDateTime(payment.issuedAt));
  }

  Widget getStatusLabel(BuildContext context) {
    final theme = Theme.of(context);
    switch (payment.entry.status) {
      case EntryStatus.pending:
        return Icon(
          Icons.hourglass_empty,
          color: theme.colorScheme.primary,
          size: 8,
        );
      case EntryStatus.done:
      default:
        return SizedBox(width: 8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(payment.entry.id),
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
      direction: loan.status.isSettled()
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          return confirmLoanPaymentDeletion(context, loan, payment.entry);
        }

        Navigator.pushNamed(
          context,
          "/loans/${loan.id}/payments/${payment.entry.id}/edit",
        );
        return false;
      },
      child: ListTile(
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(
              text:
                  "app://bandha.id/loans/${loan.id}/payments/${payment.entry.id}/detail",
            ),
          );
        },
        onTap: () {
          Navigator.pushNamed(
            context,
            "/loans/${loan.id}/payments/${payment.entry.id}/detail",
          );
        },
        dense: true,
        enableFeedback: !payment.entry.readonly,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              payment.entry.account.displayName(),
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
              payment.entry.note,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [MoneyText(payment.amount * (loan.type.isDebt() ? -1 : 1))],
        ),
      ),
    );
  }
}
