import 'package:banda/entity/fund.dart';
import 'package:banda/providers/fund_filter_provider.dart';
import 'package:banda/providers/fund_provider.dart';
import 'package:banda/views/fund_filter_view.dart';
import 'package:banda/widgets/fund_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FundListView extends StatefulWidget {
  const FundListView({super.key});

  List<Widget> actionsBuilder(BuildContext context) {
    final filterProvider = context.watch<FundFilterProvider>();
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
              builder: (_) => FundFilterView(specs: filterProvider.get()),
            ),
          );
        },
        icon: Icon(Icons.search),
      ),
    ];
  }

  @override
  State<StatefulWidget> createState() => _FundListViewState();

  Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, "/funds/new");
      },
    );
  }
}

class _FundListViewState extends State<FundListView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fundProvider = context.watch<FundProvider>();
    final filterProvider = context.watch<FundFilterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Funds",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: widget.actionsBuilder(context),
        actionsPadding: EdgeInsets.all(8),
      ),
      floatingActionButton: widget.fabBuilder(context),
      body: FutureBuilder(
        future: fundProvider.search(filterProvider.get()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
              print(snapshot.stackTrace);
            }

            return Center(child: Text("..."));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Icon(
                Icons.dashboard_customize_outlined,
                size: theme.textTheme.displayLarge!.fontSize,
              ),
            );
          }

          return SafeArea(
            child: ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                final Fund fund = snapshot.data![index];
                return FundTile(fund);
              },
            ),
          );
        },
      ),
    );
  }
}
