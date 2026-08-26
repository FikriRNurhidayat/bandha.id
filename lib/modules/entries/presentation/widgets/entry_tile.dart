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

  const EntryTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.minified = false,
    this.onTap,
    this.onLongPress,
  });

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
      readOnly: readOnly ?? false,
      minified: minified ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tile(
      selected: item.isSelected,
      onLongPress: onLongPress,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_EntryHeader(item), _EntryInfo(item)],
              ),
            ),
            if (!minified) CurrencyText(item.entity.amount, withDelta: true),
          ],
        ),
      ),
    );
  }
}

class _EntryHeader extends StatelessWidget {
  final Item<Entry> display;

  const _EntryHeader(this.display);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(display.entity.category.name, style: theme.textTheme.titleSmall),
        if (display.entity.hasReadOnlyLabels)
          LabelRow(display.entity.readOnlyLabels),
        if (display.entity.readOnly)
          Icon(Icons.lock_outlined, size: 8, color: theme.colorScheme.primary),
        _EntryStatus(display),
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
        DateTimeText(display.entity.issuedAt),
        Text(
          display.entity.journal.displayName,
          style: theme.textTheme.bodySmall,
        ),
        if (display.entity.controller?.id == null)
          Text(
            display.entity.controller!.id.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        if (display.entity.hasMutableLabels)
          LabelRow(display.entity.mutableLabels),
      ],
    );
  }
}
