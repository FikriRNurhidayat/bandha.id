import 'package:banda/entity/loan.dart';
import 'package:banda/providers/loan_filter_provider.dart';
import 'package:banda/providers/loan_provider.dart';
import 'package:banda/views/loan_edit_view.dart';
import 'package:banda/views/loan_filter_view.dart';
import 'package:banda/widgets/loan_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanListView extends StatefulWidget {
  const LoanListView({super.key});

  static List<Widget> actionsBuilder(BuildContext context) {
    final filterProvider = context.watch<LoanFilterProvider>();
    final filter = filterProvider.get();

    return [
      if (filter != null)
        IconButton(
          onPressed: () {
            filterProvider.reset();
          },
          icon: Icon(Icons.close),
        ),
      IconButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LoanFilterView(specs: filterProvider.get()),
            ),
          );
        },
        icon: Icon(Icons.search),
      ),
    ];
  }

  @override
  State<StatefulWidget> createState() => _LoanListViewState();

  static String title = "Loans";
  static IconData icon = Icons.currency_pound;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoanEditView()),
        );
      },
    );
  }
}

class _LoanListViewState extends State<LoanListView> {
  @override
  Widget build(BuildContext context) {
    final loanProvider = context.watch<LoanProvider>();
    final filterProvider = context.watch<LoanFilterProvider>();

    return FutureBuilder(
      future: loanProvider.search(filterProvider.get()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("..."));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Empty"));
        }

        return SafeArea(
          child: ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              final Loan loan = snapshot.data![index];
              return LoanTile(loan);
            },
          ),
        );
      },
    );
  }
}
