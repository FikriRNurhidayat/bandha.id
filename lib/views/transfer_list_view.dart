import 'package:banda/entity/transfer.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/views/transfer_edit_view.dart';
import 'package:banda/widgets/transfer_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransferListView extends StatefulWidget {
  const TransferListView({super.key});

  @override
  State<StatefulWidget> createState() => _TransferListViewState();

  static String title = "Transfers";
  static IconData icon = Icons.sync_alt;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TransferEditView()),
        );
      },
    );
  }
}

class _TransferListViewState extends State<TransferListView> {
  @override
  Widget build(BuildContext context) {
    final transferProvider = context.watch<TransferProvider>();

    return FutureBuilder(
      future: transferProvider.search(),
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
          child: ListView.separated(
            itemCount: snapshot.data?.length ?? 0,
            separatorBuilder: (_, __) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(),
              );
            },
            itemBuilder: (BuildContext context, int index) {
              final Transfer transfer = snapshot.data![index];
              return TransferTile(transfer);
            },
          ),
        );
      },
    );
  }
}
