import 'package:banda/entity/entry.dart';
import 'package:banda/entity/transfer.dart';
import 'package:banda/helpers/future_helper.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/widgets/entry_tile.dart';
import 'package:banda/widgets/transfer_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransferEntriesView extends StatelessWidget {
  final String id;
  const TransferEntriesView({super.key, required this.id});

  handleMenuTap(BuildContext context) {
    Navigator.of(context).pushNamed("/transfers/$id/menu");
  }

  transferBuilder(BuildContext context, Transfer transfer) {
    return TransferTile(transfer, readOnly: true);
  }

  appBarBuilder(BuildContext context, Transfer transfer) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Transfer entries",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            handleMenuTap(context);
          },
          icon: Icon(Icons.more_horiz),
        ),
      ],
      actionsPadding: EdgeInsets.all(8.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transferProvider = context.watch<TransferProvider>();
    final entryProvider = context.watch<EntryProvider>();

    return FutureBuilder(
      future: transferProvider.get(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("...")));
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Icon(
                Icons.dashboard_customize_outlined,
                size: theme.textTheme.displayLarge!.fontSize,
              ),
            ),
          );
        }

        final transfer = snapshot.data!;
        final controller = transfer.toController();

        return Scaffold(
          appBar: appBarBuilder(context, transfer),
          body: SafeArea(
            bottom: true,
            child: Column(
              children: [
                transferBuilder(context, transfer),
                FutureBuilder(
                  future: entryProvider.search(
                    specification: {
                      "controller_id_is": controller.id,
                      "controller_type_is": controller.type.label,
                    },
                  ),
                  builder: futureBuilder<List<Entry>>((context, snapshot) {
                    final entries = snapshot.data!;

                    return Expanded(
                      child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Entry entry = entries[index];
                          return EntryTile(entry);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
