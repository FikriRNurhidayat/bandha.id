import 'package:banda/entity/account.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/views/edit_account_screen.dart';
import 'package:banda/widgets/account_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListAccountScreen extends StatefulWidget {
  const ListAccountScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ListAccountScreenState();

  static String title = "Accounts";
  static IconData icon = Icons.wallet;
  static Widget fabBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditAccountScreen()),
        );
      },
    );
  }
}

class _ListAccountScreenState extends State<ListAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountProvider = context.watch<AccountProvider>();

    return FutureBuilder(
      future: accountProvider.search(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("...", style: theme.textTheme.bodySmall));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Empty", style: theme.textTheme.bodySmall));
        }

        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            final Account account = snapshot.data![index];
            return AccountTile(account);
          },
        );
      },
    );
  }
}
