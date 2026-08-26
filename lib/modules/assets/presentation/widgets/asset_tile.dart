import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/texts/currency_text.dart';
import 'package:bandha/core/presentation/widgets/texts/x_money_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/tile.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AssetTile extends StatelessWidget {
  final Item<Asset> item;
  final bool readOnly;
  final bool minified;
  final AsyncCallback? onTap;
  final AsyncCallback? onLongPress;

  const AssetTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.minified = false,
    this.onTap,
    this.onLongPress,
  });

  factory AssetTile.builder(
    Item<Asset> item, {
    bool? readOnly,
    AsyncCallback? onTap,
    AsyncCallback? onLongPress,
    bool? minified,
  }) {
    return AssetTile(
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
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        padding: minified ? null : EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.entity.name, style: theme.textTheme.titleSmall),
                  Text(item.entity.code, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (!minified)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CurrencyText(item.entity.balance)],
              ),
          ],
        ),
      ),
    );
  }
}
