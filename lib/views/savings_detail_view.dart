import 'package:banda/entity/entry.dart';
import 'package:banda/providers/savings_provider.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:banda/widgets/savings_transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingsDetailView extends StatelessWidget {
  final String id;
  const SavingsDetailView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savingsProvider = context.watch<SavingsProvider>();

    return FutureBuilder(
      future: savingsProvider.get(id),
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

        final savings = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              savings.note,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            centerTitle: true,
            actions: [
              if (savings.canDispense())
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "Release savings",
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
                                  final savingsProvider = context
                                      .read<SavingsProvider>();
                                  await savingsProvider.release(savings.id);

                                  navigator.pop();
                                } catch (error) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text("Release savings failed"),
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
          floatingActionButton: savings.canGrow()
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/savings/${savings.id}/entries/new",
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
                        savings.account.displayName(),
                        style: theme.textTheme.labelSmall,
                      ),
                      SizedBox(
                        height: 8,
                        child: LinearProgressIndicator(
                          value: savings.getProgress(),
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
                            savings.balance,
                            useSymbol: false,
                            style: theme.textTheme.labelSmall,
                          ),
                          MoneyText(
                            savings.goal,
                            useSymbol: false,
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: savingsProvider.searchEntries(savingsId: savings.id),
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
                          return SavingsTransactionTile(savings, entry);
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
