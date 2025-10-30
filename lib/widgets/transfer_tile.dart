import 'package:banda/entity/transfer.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/views/transfer_edit_view.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransferTile extends StatelessWidget {
  final Transfer transfer;
  final DateFormat dateFormat = DateFormat("yyyy/MM/dd");

  TransferTile(this.transfer, {super.key});

  String formatAmount(double value) {
    return value
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'\.?0+$'), ''); // trims .000 / .100 etc.
  }

  String getAmount(double amount) {
    final n = amount.abs();

    if (n >= 1e9) {
      return '${formatAmount(n / 1e9)}B';
    }
    if (n >= 1e6) {
      return '${formatAmount(n / 1e6)}M';
    }

    if (n >= 1e3) {
      return '${formatAmount(n / 1e3)}K';
    }

    return n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(transfer.id),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) {
        return showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("Delete transfer"),
              content: const Text(
                "Are you sure you want to remove this transfer entry?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    final navigator = Navigator.of(ctx);
                    final transferProvider = ctx.read<TransferProvider>();
                    transferProvider.remove(transfer.id).then((_) {
                      navigator.pop(true);
                    });
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => TransferEditView(transfer: transfer),
            ),
          );
        },
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Debit", style: theme.textTheme.titleSmall),
                    Text(
                      transfer.creditAccount!.name,
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      transfer.creditAccount!.holderName,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                MoneyText(transfer.credit!.amount),
              ],
            ),
            Divider(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Credit", style: theme.textTheme.titleSmall),
                Text(
                  transfer.debitAccount!.name,
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  transfer.debitAccount!.holderName,
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
