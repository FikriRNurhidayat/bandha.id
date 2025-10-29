import 'package:banda/entity/account.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/views/edit_account_screen.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountTile extends StatefulWidget {
  final Account account;

  const AccountTile(this.account, {super.key});

  @override
  State<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile> {
  Account? account;

  @override
  void initState() {
    account = widget.account;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(widget.account.id),
      confirmDismiss: (direction) async {
        final messenger = ScaffoldMessenger.of(context);

        if (direction == DismissDirection.startToEnd) {
          return showDialog<bool>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text(
                  "Delete account",
                  style: theme.textTheme.titleMedium,
                ),
                content: Text(
                  "Are you sure you want to remove this account?",
                  style: theme.textTheme.bodySmall,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx, false);
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      final navigator = Navigator.of(ctx);
                      final accountProvider = ctx.read<AccountProvider>();

                      accountProvider
                          .delete(widget.account.id)
                          .then((_) {
                            navigator.pop(true);
                          })
                          .catchError((_) {
                            messenger.showSnackBar(
                              SnackBar(content: Text("Delete account failed")),
                            );

                            navigator.pop(false);
                          });
                    },
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );
        }

        final accountProvider = context.read<AccountProvider>();

        await accountProvider.sync(widget.account.id);
        account = await accountProvider.get(widget.account.id);

        return false;
      },
      direction: DismissDirection.horizontal,
      child: ListTile(
        onLongPress: () {
          final accountProvider = context.read<AccountProvider>();
          accountProvider.sync(widget.account.id);
        },
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => EditAccountScreen(account: widget.account),
            ),
          );
        },
        title: Text(widget.account.name, style: theme.textTheme.titleSmall),
        subtitle: Text(
          widget.account.holderName,
          style: theme.textTheme.bodySmall,
        ),
        trailing: MoneyText(widget.account.balance, useSymbol: false),
      ),
    );
  }
}
