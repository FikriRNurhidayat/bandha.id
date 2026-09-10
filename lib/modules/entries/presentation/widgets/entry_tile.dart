import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/texts/currency_text.dart';
import 'package:bandha/core/presentation/widgets/texts/date_time_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/label_row.dart';
import 'package:bandha/core/presentation/widgets/tiles/tile.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EntryTile extends StatelessWidget {
  final Item<Entry> item;
  final bool readOnly;
  final bool minified;
  final AsyncCallback? onLongPress;
  final AsyncCallback? onTap;

  EntryTile(
    this.item, {
    super.key,
    this.minified = false,
    this.onTap,
    this.onLongPress,
    bool? readOnly,
  }) : readOnly = readOnly ?? item.entity.readOnly;

  factory EntryTile.builder(
    Item<Entry> item, {
    AsyncCallback? onTap,
    AsyncCallback? onLongPress,
    bool? readOnly,
    bool? minified,
  }) {
    return EntryTile(
      item,
      onTap: onTap,
      onLongPress: onLongPress,
      readOnly: readOnly,
      minified: minified ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("EntryTile.readOnly: $readOnly");

    return Tile(
      selected: item.isSelected,
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        padding: !minified ? EdgeInsets.all(16.0) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EntryHeader(item, readOnly: readOnly),
                  _EntryInfo(item),
                ],
              ),
            ),
            if (!minified) CurrencyText(item.entity.amount, mutation: true),
          ],
        ),
      ),
    );
  }
}

class _EntryHeader extends StatelessWidget {
  final Item<Entry> item;
  final bool readOnly;

  const _EntryHeader(this.item, {required this.readOnly});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(item.entity.category.name, style: theme.textTheme.titleSmall),
        if (item.entity.hasReadOnlyLabels) LabelRow(item.entity.readOnlyLabels),
        if (readOnly)
          Icon(Icons.lock_outlined, size: 8, color: theme.colorScheme.primary),
        _EntryStatus(item),
      ],
    );
  }
}

class _EntryStatus extends StatelessWidget {
  final Item<Entry> display;

  const _EntryStatus(this.display);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (display.entity.status) {
      case EntryStatus.pending:
        return Icon(
          Icons.hourglass_empty,
          color: theme.colorScheme.primary,
          size: 8,
        );
      case EntryStatus.done:
      default:
        return SizedBox(width: 8);
    }
  }
}

class _EntryInfo extends StatelessWidget {
  final Item<Entry> display;

  const _EntryInfo(this.display);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DateTimeText(display.entity.issuedAt, style: theme.textTheme.bodySmall),
        Text(
          display.entity.journal.displayName,
          style: theme.textTheme.bodySmall,
        ),
        if (display.entity.hasMutableLabels)
          LabelRow(display.entity.mutableLabels),
      ],
    );
  }
}
