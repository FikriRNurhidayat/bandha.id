import 'package:banda/entity/loan.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:banda/views/loan_edit_view.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanTile extends StatelessWidget {
  final Loan loan;

  const LoanTile(this.loan, {super.key});

  String getIssueDate() {
    return DateHelper.formatSimpleDate(loan.issuedAt);
  }

  String getSettleDate() {
    return DateHelper.formatSimpleDate(loan.settledAt);
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
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(loan.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) {
        return showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Delete loan", style: theme.textTheme.titleMedium),
              content: Text(
                "Are you sure you want to remove this loan?",
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
                    final loanProvider = context.read<LoanProvider>();
                    loanProvider
                        .delete(loan.id)
                        .then((_) => navigator.pop(true))
                        .catchError((_) {
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
        onTap: () {
          final navigator = Navigator.of(context);
          context.read<LoanProvider>().get(loan.id).then((entry) {
            navigator.push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => LoanEditView(loan: loan),
              ),
            );
          });
        },
        title: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(loan.kind.label, style: theme.textTheme.titleSmall),
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
              "${getIssueDate()} — ${getSettleDate()}",
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              loan.party!.name,
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
            if (loan.fee != null)
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
