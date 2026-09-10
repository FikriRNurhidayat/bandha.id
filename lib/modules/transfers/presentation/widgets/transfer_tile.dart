import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/texts/currency_text.dart';
import 'package:bandha/core/presentation/widgets/texts/date_text.dart';
import 'package:bandha/core/presentation/widgets/texts/time_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/tile.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TransferTile extends StatelessWidget {
  final Item<Transfer> item;
  final bool readOnly;
  final bool minified;
  final AsyncCallback? onTap;
  final AsyncCallback? onLongPress;

  const TransferTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.minified = false,
    this.onTap,
    this.onLongPress,
  });

  factory TransferTile.builder(
    Item<Transfer> item, {
    AsyncCallback? onTap,
    AsyncCallback? onLongPress,
    bool? readOnly,
    bool? minified,
  }) {
    return TransferTile(
      item,
      onTap: onTap,
      onLongPress: onLongPress,
      readOnly: readOnly ?? false,
      minified: minified ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tile(
      selected: item.isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DateText(
                  item.entity.issuedAt,
                  style: theme.textTheme.labelSmall,
                ),
                TimeText(
                  TimeOfDay.fromDateTime(item.entity.issuedAt),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.entity.credit.journal.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.entity.credit.journal.holderName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.entity.debit.journal.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.entity.debit.journal.holderName,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    CurrencyText(
                      item.entity.credit.amount,
                      style: theme.textTheme.labelSmall,
                      currency: item.entity.credit.journal.asset.code,
                      mutation: true,
                    ),
                    if (item.entity.creditFee != null)
                      CurrencyText(
                        item.entity.creditFee!.amount,
                        style: theme.textTheme.labelSmall,
                        currency: item.entity.creditFee!.journal.asset.code,
                        mutation: true,
                      ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    CurrencyText(
                      item.entity.debit.amount,
                      style: theme.textTheme.labelSmall,
                      currency: item.entity.debit.journal.asset.code,
                      mutation: true,
                    ),
                    if (item.entity.debitFee != null)
                      CurrencyText(
                        item.entity.debitFee!.amount,
                        style: theme.textTheme.labelSmall,
                        currency: item.entity.debitFee!.journal.asset.code,
                        mutation: true,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
