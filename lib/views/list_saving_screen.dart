import 'package:banda/entity/saving.dart';
import 'package:banda/providers/saving_filter_provider.dart';
import 'package:banda/providers/saving_provider.dart';
import 'package:banda/views/edit_saving_screen.dart';
import 'package:banda/views/filter_saving_screen.dart';
import 'package:banda/widgets/empty.dart';
import 'package:banda/widgets/saving_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListSavingScreen extends StatefulWidget {
  const ListSavingScreen({super.key});

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
              builder: (_) => FilterSavingScreen(specs: filterProvider.get()),
            ),
          );
        },
        icon: Icon(Icons.filter_list_alt),
      ),
    ];
  }

  @override
  State<StatefulWidget> createState() => _ListSavingScreenState();

  static String title = "Savings";
  static IconData icon = Icons.currency_pound;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditSavingScreen()),
        );
      },
    );
  }
}

class _ListSavingScreenState extends State<ListSavingScreen> {
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

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SafeArea(
              child: ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final Saving saving = snapshot.data![index];
                  return SavingTile(saving);
                },
              ),
            );
          }

          if (snapshot.hasError) {
            return Empty("Error", icon: Icons.warning);
          }

          return Empty("Savings you add will appear here");
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
