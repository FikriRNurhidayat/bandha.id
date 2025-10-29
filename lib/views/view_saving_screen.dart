import 'package:banda/entity/entry.dart';
import 'package:banda/entity/saving.dart';
import 'package:banda/providers/saving_provider.dart';
import 'package:banda/views/edit_saving_entry_screen.dart';
import 'package:banda/widgets/empty.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:banda/widgets/saving_entry_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewSavingScreen extends StatelessWidget {
  final Saving saving;
  const ViewSavingScreen({super.key, required this.saving});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savingProvider = context.watch<SavingProvider>();

    return FutureBuilder(
      future: savingProvider.get(saving.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("...")));
        }

        if (!snapshot.hasData) {
          return Scaffold(body: Center(child: Text("empty")));
        }

        final saving = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              saving.note,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            centerTitle: true,
            actions: [
              if (saving.canDispense())
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "Release saving",
                            style: theme.textTheme.titleMedium,
                          ),
                          alignment: Alignment.center,
                          content: Text(
                            "Saving deposit will be released as entry",
                            style: theme.textTheme.bodySmall,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  final savingProvider = context
                                      .read<SavingProvider>();
                                  await savingProvider.release(saving.id);

                                  navigator.pop();
                                } catch (error) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text("Release saving failed"),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.done_all),
                ),
            ],
            actionsPadding: EdgeInsets.all(8.0),
          ),
          floatingActionButton: saving.canGrow()
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditSavingEntryScreen(saving: saving),
                      ),
                    );
                  },
                )
              : null,
          body: SafeArea(
            bottom: true,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    spacing: 8,
                    children: [
                      Text(
                        saving.account!.displayName(),
                        style: theme.textTheme.labelSmall,
                      ),
                      SizedBox(
                        height: 8,
                        child: LinearProgressIndicator(
                          value: saving.getProgress(),
                          backgroundColor: theme.colorScheme.surfaceContainer,
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MoneyText(
                            saving.balance,
                            useSymbol: false,
                            style: theme.textTheme.labelSmall,
                          ),
                          MoneyText(
                            saving.goal,
                            useSymbol: false,
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: savingProvider.searchEntries(savingId: saving.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("..."));
                    }

                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }

                    final entries = snapshot.data!;

                    if (entries.isEmpty) {
                      return SizedBox.shrink();
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Entry entry = entries[index];
                          return SavingEntryTile(saving, entry);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
