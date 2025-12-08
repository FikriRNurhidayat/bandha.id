import 'package:banda/entity/savings.dart';
import 'package:banda/providers/savings_filter_provider.dart';
import 'package:banda/providers/savings_provider.dart';
import 'package:banda/views/savings_filter_view.dart';
import 'package:banda/widgets/savings_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingsListView extends StatefulWidget {
  const SavingsListView({super.key});

  List<Widget> actionsBuilder(BuildContext context) {
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

  Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, "/savings/new");
      },
    );
  }
}

class _SavingsListViewState extends State<SavingsListView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savingsProvider = context.watch<SavingsProvider>();
    final filterProvider = context.watch<SavingsFilterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Savings",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: widget.actionsBuilder(context),
        actionsPadding: EdgeInsets.all(8),
      ),
      floatingActionButton: widget.fabBuilder(context),
      body: FutureBuilder(
        future: savingsProvider.search(filterProvider.get()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("..."));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Icon(Icons.dashboard_customize_outlined, size: theme.textTheme.displayLarge!.fontSize));
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
      ),
    );
  }
}
