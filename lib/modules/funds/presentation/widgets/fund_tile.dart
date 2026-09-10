import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/texts/currency_text.dart';
import 'package:bandha/core/presentation/widgets/texts/date_text.dart';
import 'package:bandha/core/presentation/widgets/texts/time_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/label_row.dart';
import 'package:bandha/core/presentation/widgets/tiles/tile.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FundTile extends StatelessWidget {
  final Item<Fund> item;
  final bool readOnly;
  final bool minified;
  final AsyncCallback? onTap;
  final AsyncCallback? onLongPress;

  const FundTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.minified = false,
    this.onTap,
    this.onLongPress,
  });

  factory FundTile.builder(
    Item<Fund> item, {
    AsyncCallback? onLongPress,
    AsyncCallback? onTap,
    bool? readOnly,
    bool? minified,
  }) {
    return FundTile(
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
        padding: !minified ? EdgeInsets.all(16) : null,
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.entity.category.name,
                          style: theme.textTheme.titleSmall,
                        ),
                        if (item.entity.status.isReleased)
                          Icon(
                            Icons.lock_outlined,
                            size: 8,
                            color: theme.colorScheme.primary,
                          ),
                        if (item.entity.balance != 0)
                          CurrencyText(
                            item.entity.balance,
                            style: theme.textTheme.labelSmall,
                          ),
                      ],
                    ),
                    if (!minified)
                      DateText(
                        item.entity.createdAt,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.entity.journal.displayName,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (!minified)
                      TimeText(
                        TimeOfDay.fromDateTime(item.entity.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
            if (!minified)
              Column(
                spacing: 8,
                children: [
                  LinearProgressIndicator(
                    value: item.entity.progress,
                    color: theme.colorScheme.onSurface,
                    backgroundColor: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    minHeight: theme.textTheme.labelSmall?.fontSize,
                  ),
                  Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          item.entity.labels.isNotEmpty
                              ? LabelRow(item.entity.labels)
                              : SizedBox(),
                        ],
                      ),
                      Row(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CurrencyText(
                            item.entity.raised,
                            style: theme.textTheme.bodySmall,
                          ),
                          Text('/', style: theme.textTheme.bodySmall),
                          CurrencyText(
                            item.entity.amount,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
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
