import 'package:banda/entity/bill.dart';
import 'package:banda/providers/bill_filter_provider.dart';
import 'package:banda/providers/bill_provider.dart';
import 'package:banda/views/bill_filter_view.dart';
import 'package:banda/widgets/bill_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillListView extends StatefulWidget {
  const BillListView({super.key});

  List<Widget> actionsBuilder(BuildContext context) {
    final filterProvider = context.watch<BillFilterProvider>();
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
              builder: (_) => BillFilterView(specs: filterProvider.get()),
            ),
          );
        },
        icon: Icon(Icons.search),
      ),
    ];
  }

  @override
  State<StatefulWidget> createState() => _BillListViewState();

  Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, "/bills/new");
      },
    );
  }
}

class _BillListViewState extends State<BillListView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final billProvider = context.watch<BillProvider>();
    final filterProvider = context.watch<BillFilterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bills",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: widget.actionsBuilder(context),
        actionsPadding: EdgeInsets.all(8),
      ),
      floatingActionButton: widget.fabBuilder(context),
      body: FutureBuilder(
        future: billProvider.search(filterProvider.get()),
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
                final Bill bill = snapshot.data![index];
                return BillTile(bill);
              },
            ),
          );
        },
      ),
    );
  }
}
