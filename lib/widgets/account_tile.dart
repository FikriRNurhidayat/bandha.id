import 'package:banda/entity/account.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/views/edit_account_screen.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountTile extends StatelessWidget {
  final Account account;

  const AccountTile(this.account, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("Please Confirm"),
              content: const Text(
                "Are you sure you want to remove this account?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    final accountProvider = context.read<AccountProvider>();

                    accountProvider.delete(account.id);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => EditAccountScreen(account: account),
          ),
        );
      },
      title: Text(account.name),
      subtitle: Text(account.holderName),
      trailing: account.balance != null ? MoneyText(account.balance!, useSymbol: false) : null,
    );
  }
}
