import 'package:banda/entity/transfer.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/views/edit_transfer_screen.dart';
import 'package:banda/widgets/transfer_tile.dart';
import 'package:banda/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListTransferScreen extends StatefulWidget {
  const ListTransferScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ListTransferScreenState();

  static String title = "Transfers";
  static IconData icon = Icons.sync_alt;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditTransferScreen()),
        );
      },
    );
  }
}

class _ListTransferScreenState extends State<ListTransferScreen> {
  @override
  Widget build(BuildContext context) {
    final transferProvider = context.watch<TransferProvider>();

    return FutureBuilder(
      future: transferProvider.search(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SafeArea(
              child: ListView.builder(
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final Transfer transfer = snapshot.data![index];
                  return TransferTile(transfer);
                },
              ),
            );
          }

          return Empty("Transfers you add will appear here");
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
