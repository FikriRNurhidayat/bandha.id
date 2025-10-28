import 'package:banda/entity/entry.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/providers/entry_filter_provider.dart';
import 'package:banda/views/edit_entry_screen.dart';
import 'package:banda/views/filter_entry_screen.dart';
import 'package:banda/widgets/entry_tile.dart';
import 'package:flutter/material.dart';
import "package:provider/provider.dart";

class ListEntryScreen extends StatefulWidget {
  const ListEntryScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ListEntryScreenState();

  static String title = "Entries";
  static IconData icon = Icons.book;

  static List<Widget> actionsBuilder(BuildContext context) {
    final filterProvider = context.watch<EntryFilterProvider>();
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
              builder: (_) => FilterEntryScreen(specification: filterProvider.get()),
            ),
          );
        },
        icon: Icon(Icons.filter_list_alt),
      ),
    ];
  }

  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditEntryScreen()),
        );
      },
    );
  }
}

class _ListEntryScreenState extends State<ListEntryScreen> {
  @override
  Widget build(BuildContext context) {
    final entryProvider = context.watch<EntryProvider>();
    final filterProvider = context.watch<EntryFilterProvider>();

    return FutureBuilder(
      future: entryProvider.search(spec: filterProvider.get()),
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

        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            final Entry entry = snapshot.data![index];
            return EntryTile(entry);
          },
        );
      },
    );
  }
}
