import 'package:banda/entity/bill.dart';
import 'package:banda/providers/bill_filter_provider.dart';
import 'package:banda/providers/bill_provider.dart';
import 'package:banda/views/bill_edit_view.dart';
import 'package:banda/views/bill_filter_view.dart';
import 'package:banda/widgets/bill_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BillListView extends StatefulWidget {
  const BillListView({super.key});

  static List<Widget> actionsBuilder(BuildContext context) {
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

  static String title = "Bills";
  static IconData icon = Icons.currency_pound;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BillEditView()),
        );
      },
    );
  }
}

class _BillListViewState extends State<BillListView> {
  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final filterProvider = context.watch<BillFilterProvider>();

    return FutureBuilder(
      future: billProvider.search(filterProvider.get()),
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
              final Bill bill = snapshot.data![index];
              return BillTile(bill);
            },
          ),
        );
      },
    );
  }
}
