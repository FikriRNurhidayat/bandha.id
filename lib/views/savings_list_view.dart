import 'package:banda/entity/savings.dart';
import 'package:banda/providers/savings_filter_provider.dart';
import 'package:banda/providers/savings_provider.dart';
import 'package:banda/views/savings_edit_view.dart';
import 'package:banda/views/savings_filter_view.dart';
import 'package:banda/widgets/savings_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingsListView extends StatefulWidget {
  const SavingsListView({super.key});

  static List<Widget> actionsBuilder(BuildContext context) {
    final filterProvider = context.watch<SavingsFilterProvider>();
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
              builder: (_) => SavingsFilterView(specs: filterProvider.get()),
            ),
          );
        },
        icon: Icon(Icons.search),
      ),
    ];
  }

  @override
  State<StatefulWidget> createState() => _SavingsListViewState();

  static String title = "Savings";
  static IconData icon = Icons.currency_pound;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SavingsEditView()),
        );
      },
    );
  }
}

class _SavingsListViewState extends State<SavingsListView> {
  @override
  Widget build(BuildContext context) {
    final savingsProvider = context.watch<SavingsProvider>();
    final filterProvider = context.watch<SavingsFilterProvider>();

    return FutureBuilder(
      future: savingsProvider.search(filterProvider.get()),
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
              final Savings savings = snapshot.data![index];
              return SavingTile(savings);
            },
          ),
        );
      },
    );
  }
}
