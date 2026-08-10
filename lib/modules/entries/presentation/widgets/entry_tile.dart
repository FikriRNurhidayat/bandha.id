import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/texts/x_date_time_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_dismissible.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_label_row.dart';
import 'package:bandha/core/presentation/widgets/texts/x_money_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_tile.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EntryTile extends StatelessWidget {
  final Item<Entry> item;
  final bool readOnly;
  final AsyncCallback? onDelete;

  const EntryTile(this.item, {super.key, this.readOnly = false, this.onDelete});

  factory EntryTile.builder(Item<Entry> item, {AsyncCallback? onDelete}) {
    return EntryTile(item, onDelete: onDelete);
  }

  Future<bool?> handleDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      await onDelete?.call();
      return true;
    }

    Navigator.pushNamed<bool>(context, "/entries/${item.entity.id}/edit");
    return false;
  }

  void handleTap(BuildContext context) {
    Navigator.pushNamed(context, "/entries/${item.entity.id}/detail");
  }

  @override
  Widget build(BuildContext context) {
    return XDismissible(
      key: Key(item.entity.id),
      dismissible: true,
      confirmDismiss: (DismissDirection direction) {
        return handleDismiss(context, direction);
      },
      child: XTile(
        onTap: () {
          handleTap(context);
        },
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
              XMoneyText(item.entity.amount),
            ],
          ),
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
          XLabelRow(display.entity.readOnlyLabels),
        if (display.entity.readOnly)
          Icon(Icons.lock, size: 8, color: theme.colorScheme.primary),
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
        XDateTimeText(display.entity.issuedAt),
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
          XLabelRow(display.entity.mutableLabels),
      ],
    );
  }
}
