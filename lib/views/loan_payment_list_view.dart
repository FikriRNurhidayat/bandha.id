import 'package:banda/entity/loan.dart';
import 'package:banda/entity/loan_payment.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/helpers/future_helper.dart';
import 'package:banda/helpers/money_helper.dart';
import 'package:banda/helpers/type_helper.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:banda/widgets/loan_payment_tile.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanPaymentListView extends StatelessWidget {
  final String id;
  const LoanPaymentListView({super.key, required this.id});

  handleTap(BuildContext context) {
    Navigator.of(context).pushNamed("/loans/$id/detail");
  }

  handleMoreTap(BuildContext context) {
    Navigator.of(context).pushNamed("/loans/$id/menu");
  }

  fabBuilder(BuildContext context, Loan loan) {
    if (loan.status.isSettled()) return null;

    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed("/loans/$id/payments/new");
      },
      child: Icon(Icons.add),
    );
  }

  appBarBuilder(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Loan",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            handleMoreTap(context);
          },
          icon: Icon(Icons.more_horiz),
        ),
      ],
      actionsPadding: EdgeInsets.all(8),
    );
  }

  Widget getLoanStatusLabel(BuildContext context, Loan loan) {
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
        return Icon(Icons.check, color: theme.colorScheme.primary, size: 8);
    }
  }

  String getIssueDate(Loan loan) {
    return DateHelper.formatSimpleDate(loan.issuedAt);
  }

  String getIssueTime(Loan loan) {
    return DateHelper.formatTime(TimeOfDay.fromDateTime(loan.issuedAt));
  }

  progressBuilder(BuildContext context, Loan loan) {
    final theme = Theme.of(context);

    return Column(
      spacing: 8,
      children: [
        SizedBox(
          height: 8,
          child: LinearProgressIndicator(
            value: loan.completion,
            backgroundColor: theme.colorScheme.surfaceContainer,
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MoneyText(
              loan.paid,
              useSymbol: false,
              style: theme.textTheme.labelSmall,
            ),
            MoneyText(
              loan.amount,
              useSymbol: false,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }

  detailBuilder(BuildContext context, Loan loan) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(loan.type.label, style: theme.textTheme.titleSmall),
            Badge(
              label: getLoanStatusLabel(context, loan),
              textColor: theme.colorScheme.onSurface,
              backgroundColor: Colors.transparent,
            ),
            if (!isZero(loan.fee))
              Badge(
                padding: EdgeInsets.zero,
                label: Text(MoneyHelper.normalize(loan.fee!)),
                textColor: theme.colorScheme.onSurface,
                backgroundColor: Colors.transparent,
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "${getIssueDate(loan)} at ${getIssueTime(loan)}",
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
      ],
    );
  }

  progressLabelBuilder(BuildContext context, Loan loan) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              MoneyHelper.normalize(loan.paid),
              style: theme.textTheme.bodyLarge,
            ),
            Text("/", style: theme.textTheme.bodySmall),
            Text(
              MoneyHelper.normalize(loan.amount),
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
        Badge(
          padding: EdgeInsets.all(0),
          label: Text(loan.status.label, style: theme.textTheme.bodySmall),
          textColor: theme.colorScheme.onSurface,
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }

  loanBuilder(BuildContext context, Loan loan) {
    return Material(
      child: InkWell(
        onTap: () {
          handleTap(context);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  detailBuilder(context, loan),
                  progressLabelBuilder(context, loan),
                ],
              ),
              progressBuilder(context, loan),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();

    return FutureBuilder(
      future: loanProvider.get(id),
      builder: futureBuilder((context, snapshot) {
        final loan = snapshot.data as Loan;

        return Scaffold(
          appBar: appBarBuilder(context),
          floatingActionButton: fabBuilder(context, loan),
          body: Column(
            children: [
              loanBuilder(context, loan),
              FutureBuilder(
                future: loanProvider.searchPayments(id),
                builder: futureBuilder((context, snapshot) {
                  final payments = snapshot.data as List<LoanPayment>;

                  return Expanded(
                    child: ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (BuildContext context, int index) {
                        final payment = payments[index];
                        return LoanPaymentTile(payment: payment, loan: loan);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}
