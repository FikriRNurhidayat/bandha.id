import 'package:banda/entity/transfer.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/providers/transfer_provider.dart';
import 'package:banda/views/edit_transfer_screen.dart';
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Credit", style: theme.textTheme.titleSmall),
                Text(
                  transfer.creditAccount!.name,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  transfer.creditAccount!.holderName,
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.chevron_left, size: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MoneyText(
                      transfer.amount,
                      useSymbol: false,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      DateHelper.formatSimpleDate(transfer.issuedAt),
                      style: theme.textTheme.labelSmall,
                    ),
                    if (transfer.fee != null)
                      MoneyText(
                        transfer.fee!,
                        useSymbol: false,
                        style: theme.textTheme.labelSmall,
                      )
                    else
                      SizedBox.shrink(),
                  ],
                ),
                Icon(Icons.chevron_right, size: 8),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Debit", style: theme.textTheme.titleSmall),
                Text(
                  transfer.debitAccount!.name,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  transfer.debitAccount!.holderName,
                  style: theme.textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
