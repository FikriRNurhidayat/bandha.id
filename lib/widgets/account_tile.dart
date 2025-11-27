import 'package:banda/entity/account.dart';
import 'package:banda/providers/account_provider.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      background: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      secondaryBackground: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
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

        Navigator.pushNamed(context, "/accounts/${account!.id}/edit");
        return false;
      },
      direction: DismissDirection.horizontal,
      child: ListTile(
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(
              text: "app://banda.io/accounts/${account!.id}/detail",
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
