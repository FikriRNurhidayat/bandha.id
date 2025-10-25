import 'package:banda/entity/loan.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanTile extends StatelessWidget {
  final Loan loan;

  const LoanTile(this.loan, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      title: Text(loan.amount.toString()),
    );
  }
}
