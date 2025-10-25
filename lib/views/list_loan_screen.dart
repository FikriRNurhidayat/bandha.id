import 'package:banda/entity/loan.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:banda/views/edit_loan_screen.dart';
import 'package:banda/widgets/empty.dart';
import 'package:banda/widgets/loan_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListLoanScreen extends StatefulWidget {
  const ListLoanScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ListLoanScreenState();

  static String title = "Loans";
  static IconData icon = Icons.currency_pound;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditLoanScreen()),
        );
      },
    );
  }
}

class _ListLoanScreenState extends State<ListLoanScreen> {
  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();

    return FutureBuilder(
      future: loanProvider.search(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SafeArea(
              child: ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final Loan loan = snapshot.data![index];
                  return LoanTile(loan);
                },
              ),
            );
          }

          return Empty("Transfers you add will appear here");
        }

        return CircularProgressIndicator();
      },
    );
  }
}
