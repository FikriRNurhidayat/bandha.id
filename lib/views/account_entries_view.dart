import 'package:banda/entity/entry.dart';
import 'package:banda/entity/account.dart';
import 'package:banda/helpers/future_helper.dart';
import 'package:banda/helpers/money_helper.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/providers/entry_provider.dart';
import 'package:banda/widgets/entry_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountEntriesView extends StatelessWidget {
  final String id;
  const AccountEntriesView({super.key, required this.id});

  handleMenuTap(BuildContext context) {
    Navigator.of(context).pushNamed("/accounts/$id/menu");
  }

  handleTap(BuildContext context) {
    Navigator.of(context).pushNamed("/accounts/$id/detail");
  }

  accountBuilder(BuildContext context, Account account) {
    final theme = Theme.of(context);

    return Material(
      color: Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          handleTap(context);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, style: theme.textTheme.titleSmall),
                  Text(account.holderName, style: theme.textTheme.bodySmall),
                  Text(account.kind.label, style: theme.textTheme.labelSmall),
                ],
              ),
              Text(
                MoneyHelper.normalize(account.balance),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  appBarBuilder(BuildContext context, Account account) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Account entries",
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
    final accountProvider = context.watch<AccountProvider>();
    final entryProvider = context.watch<EntryProvider>();

    return FutureBuilder(
      future: accountProvider.get(id),
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

        final account = snapshot.data!;

        return Scaffold(
          appBar: appBarBuilder(context, account),
          body: SafeArea(
            bottom: true,
            child: Column(
              children: [
                accountBuilder(context, account),
                FutureBuilder(
                  future: entryProvider.search(
                    specification: {
                      "account_in": [account.id],
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
