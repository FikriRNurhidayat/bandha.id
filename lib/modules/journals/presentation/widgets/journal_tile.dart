import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/texts/currency_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/tile.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class JournalTile extends StatelessWidget {
  final Item<Journal> item;
  final bool readOnly;
  final bool minified;
  final AsyncCallback? onTap;
  final AsyncCallback? onLongPress;

  const JournalTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.minified = false,
    this.onTap,
    this.onLongPress,
  });

  factory JournalTile.builder(
    Item<Journal> item, {
    AsyncCallback? onTap,
    AsyncCallback? onLongPress,
    bool? readOnly,
    bool? minified,
  }) {
    return JournalTile(
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
        padding: !minified ? const EdgeInsets.all(16.0) : null,
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
                  Text(
                    item.entity.holderName,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!minified) CurrencyText(item.entity.balance),
          ],
        ),
      ),
    );
  }
}
