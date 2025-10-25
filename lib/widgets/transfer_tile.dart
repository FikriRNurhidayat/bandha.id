import 'package:banda/entity/transfer.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/views/edit_transfer_screen.dart';
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

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => EditTransferScreen(transfer: transfer),
          ),
        );
      },
      onLongPress: () {
        showDialog(
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
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    final transferProvider = context.read<TransferProvider>();

                    transferProvider.remove(transfer.id);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      },
      title: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From', style: theme.textTheme.titleSmall),
                  Text(
                    transfer.fromAccountName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.apply(
                      fontFamily: theme.textTheme.headlineSmall!.fontFamily,
                    ),
                  ),
                  Text(
                    transfer.fromAccountHolderName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            Column(children: [Icon(Icons.chevron_right)]),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (transfer.fee != null)
                    Text(
                      getAmount(transfer.fee!),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall!.apply(
                        fontFamily: theme.textTheme.headlineSmall!.fontFamily,
                      ),
                    ),
                  Text(
                    getAmount(transfer.amount),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium!.apply(
                      fontFamily: theme.textTheme.headlineSmall!.fontFamily,
                    ),
                  ),
                  Text(
                    dateFormat.format(transfer.timestamp),
                    style: theme.textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Column(children: [Icon(Icons.chevron_right)]),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To', style: theme.textTheme.titleSmall),
                  Text(
                    transfer.toAccountName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.apply(
                      fontFamily: theme.textTheme.bodySmall!.fontFamily,
                    ),
                  ),
                  Text(
                    transfer.toAccountHolderName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
