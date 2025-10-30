import 'package:banda/entity/saving.dart';
import 'package:banda/providers/saving_filter_provider.dart';
import 'package:banda/providers/saving_provider.dart';
import 'package:banda/views/edit_saving_view.dart';
import 'package:banda/views/filter_saving_view.dart';
import 'package:banda/widgets/saving_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListSavingView extends StatefulWidget {
  const ListSavingView({super.key});

  static List<Widget> actionsBuilder(BuildContext context) {
    final filterProvider = context.watch<SavingFilterProvider>();
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
              builder: (_) => FilterSavingView(specs: filterProvider.get()),
            ),
          );
        },
        icon: Icon(Icons.filter_list_alt),
      ),
    ];
  }

  @override
  State<StatefulWidget> createState() => _ListSavingViewState();

  static String title = "Savings";
  static IconData icon = Icons.currency_pound;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditSavingView()),
        );
      },
    );
  }
}

class _ListSavingViewState extends State<ListSavingView> {
  @override
  Widget build(BuildContext context) {
    final savingProvider = context.watch<SavingProvider>();
    final filterProvider = context.watch<SavingFilterProvider>();

    return FutureBuilder(
      future: savingProvider.search(filterProvider.get()),
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
              final Saving saving = snapshot.data![index];
              return SavingTile(saving);
            },
          ),
        );
      },
    );
  }
}
