import 'package:banda/providers/loan_provider.dart';
import 'package:banda/widgets/field.dart';
import 'package:banda/widgets/loan_payment_tile.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanPaymentListView extends StatelessWidget {
  final String id;
  const LoanPaymentListView({super.key, required this.id});

  handleMoreTap(BuildContext context) {
    Navigator.of(context).pushNamed("/loans/$id/menu");
  }

  fabBuilder(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed("/loans/$id/payments/new");
      },
      child: Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loanProvider = context.watch<LoanProvider>();

    return FutureBuilder(
      future: loanProvider.get(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("...")));
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Icon(
                Icons.dashboard_customize_outlined,
                size: theme.textTheme.displayLarge!.fontSize,
              ),
            ),
          );
        }

        final loan = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
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
          ),
          floatingActionButton: !loan.status.isSettled()
              ? fabBuilder(context)
              : null,
          body: Column(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pushNamed("/loans/$id/detail");
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      spacing: 8,
                      children: [
                        Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Field.start(
                                labelText: "Type",
                                valueText: loan.type.label,
                              ),
                            ),
                            Expanded(
                              child: Field.center(
                                labelText: "Status",
                                valueText: loan.status.label,
                              ),
                            ),
                            Expanded(
                              child: Field.end(
                                labelText: "Party",
                                valueText: loan.party.name,
                              ),
                            ),
                          ],
                        ),
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
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: loanProvider.searchPayments(id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      if (kDebugMode) {
                        print(snapshot.error);
                        print(snapshot.stackTrace);
                      }

                      return Scaffold(body: Center(child: Text("...")));
                    }

                    if (!snapshot.hasData) {
                      return Scaffold(
                        body: Center(
                          child: Icon(
                            Icons.dashboard_customize_outlined,
                            size: theme.textTheme.displayLarge!.fontSize,
                          ),
                        ),
                      );
                    }

                    final payments = snapshot.data!;

                    return ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, i) {
                        final payment = payments[i];
                        return LoanPaymentTile(payment: payment, loan: loan);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
