import 'package:banda/entity/account.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/views/account_edit_view.dart';
import 'package:banda/widgets/account_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountListView extends StatefulWidget {
  const AccountListView({super.key});

  @override
  State<StatefulWidget> createState() => _AccountListViewState();

  Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AccountEditView()),
        );
      },
    );
  }
}

class _AccountListViewState extends State<AccountListView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountProvider = context.watch<AccountProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Accounts",
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actionsPadding: EdgeInsets.all(8),
      ),
      floatingActionButton: widget.fabBuilder(context),
      body: FutureBuilder(
        future: accountProvider.search(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("...", style: theme.textTheme.bodySmall));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Icon(Icons.dashboard_customize_outlined, size: theme.textTheme.displayLarge!.fontSize));
          }

          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              final Account account = snapshot.data![index];
              return AccountTile(account);
            },
          );
        },
      ),
    );
  }
}
