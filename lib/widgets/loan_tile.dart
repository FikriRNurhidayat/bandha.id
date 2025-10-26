import 'package:banda/entity/loan.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:banda/views/edit_loan_screen.dart';
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
          Icons.circle_outlined,
          color: theme.colorScheme.primary,
          size: 4,
        );
      case LoanStatus.overdue:
        return Icon(
          Icons.square_sharp,
          color: theme.colorScheme.primary,
          size: 4,
        );
      case LoanStatus.settled:
        return Icon(Icons.circle, color: theme.colorScheme.primary, size: 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        final navigator = Navigator.of(context);
        context.read<LoanProvider>().get(loan.id).then((entry) {
          navigator.push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => EditLoanScreen(loan: loan),
            ),
          );
        });
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("Please Confirm"),
              content: const Text("Are you sure you want to remove this loan?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    final loanProvider = context.read<LoanProvider>();

                    loanProvider.remove(loan.id);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
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
            loan.account!.displayName(),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
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
      trailing: MoneyText(loan.amount, useSymbol: false),
    );
  }
}
