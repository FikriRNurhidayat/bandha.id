import 'package:banda/entity/budget.dart';
import 'package:banda/providers/budget_filter_provider.dart';
import 'package:banda/providers/budget_provider.dart';
import 'package:banda/views/budget_edit_view.dart';
import 'package:banda/views/budget_filter_view.dart';
import 'package:banda/widgets/budget_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BudgetListView extends StatefulWidget {
  const BudgetListView({super.key});

  static List<Widget> actionsBuilder(BuildContext context) {
    final filterProvider = context.watch<BudgetFilterProvider>();
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
              builder: (_) => BudgetFilterView(specs: filterProvider.get()),
            ),
          );
        },
        icon: Icon(Icons.search),
      ),
    ];
  }

  @override
  State<StatefulWidget> createState() => _BudgetListViewState();

  static String title = "Budgets";
  static IconData icon = Icons.currency_pound;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BudgetEditView()),
        );
      },
    );
  }
}

class _BudgetListViewState extends State<BudgetListView> {
  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final filterProvider = context.watch<BudgetFilterProvider>();

    return FutureBuilder(
      future: budgetProvider.search(filterProvider.get()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          print(snapshot.stackTrace);
          return Center(child: Text("..."));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Empty"));
        }

        return SafeArea(
          child: ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              final Budget budget = snapshot.data![index];
              return BudgetTile(budget);
            },
          ),
        );
      },
    );
  }
}
