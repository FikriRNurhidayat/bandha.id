import 'package:banda/entity/account.dart';
import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountTile extends StatefulWidget {
  final Account account;

  const AccountTile(this.account, {super.key});

  @override
  State<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile> {
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
        if (direction == DismissDirection.startToEnd) {
          return confirmAccountDeletion(context, widget.account);
        }

        Navigator.pushNamed(context, "/accounts/${widget.account.id}/edit");
        return false;
      },
      direction: DismissDirection.horizontal,
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            "/accounts/${widget.account.id}/entries",
          );
        },
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(
              text: "app://bandha.id/accounts/${widget.account.id}/detail",
            ),
          );
        },
        title: Text(widget.account.name, style: theme.textTheme.titleSmall),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.account.holderName, style: theme.textTheme.bodySmall),
            Text(widget.account.kind.label, style: theme.textTheme.labelSmall),
          ],
        ),
        trailing: MoneyText(widget.account.balance, useSymbol: false),
      ),
    );
  }
}
