import 'package:banda/entity/account.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/views/edit_account_screen.dart';
import 'package:banda/widgets/account_tile.dart';
import 'package:banda/widgets/empty.dart';
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
    final accountProvider = context.watch<AccountProvider>();

    return FutureBuilder(
      future: accountProvider.withBalances(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Empty("Something went wrong", icon: Icons.error);
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                final Account account = snapshot.data![index];
                return AccountTile(account);
              },
            );
          }

          return Empty("Accounts you add appear here.");
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
