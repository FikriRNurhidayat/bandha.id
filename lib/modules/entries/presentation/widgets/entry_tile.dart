import 'package:bandha/core/presentation/widgets/app_date_time_text.dart';
import 'package:bandha/core/presentation/widgets/app_dismissible.dart';
import 'package:bandha/core/presentation/widgets/app_label_row.dart';
import 'package:bandha/core/presentation/widgets/app_money_text.dart';
import 'package:bandha/core/presentation/widgets/app_tile.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/models/entry_display.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EntryTile extends StatelessWidget {
  final EntryDisplay display;
  final bool readOnly;
  final AsyncCallback? onDelete;

  const EntryTile(
    this.display, {
    super.key,
    this.readOnly = false,
    this.onDelete,
  });

  Future<bool?> handleDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      await onDelete?.call();
      return true;
    }

    Navigator.pushNamed<bool>(context, "/entries/${display.entry.id}/edit");
    return false;
  }

  void handleTap(BuildContext context, EntryDisplay model) {
    Navigator.pushNamed(context, "/entries/${model.entry.id}/detail");
  }

  @override
  Widget build(BuildContext context) {
    return AppDismissible(
      key: Key(display.entry.id),
      dismissible: true,
      confirmDismiss: (DismissDirection direction) {
        return handleDismiss(context, direction);
      },
      child: AppTile(
        onTap: () {
          handleTap(context, display);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_EntryHeader(display), _EntryInfo(display)],
              ),
            ),
            AppMoneyText(display.entry.amount),
          ],
        ),
      ),
    );
  }
}

class _EntryHeader extends StatelessWidget {
  final EntryDisplay display;

  const _EntryHeader(this.display);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(display.entry.category.name, style: theme.textTheme.titleSmall),
        if (display.hasReadOnlyLabels) AppLabelRow(display.readOnlyLabels),
        if (display.entry.readOnly)
          Icon(Icons.lock, size: 8, color: theme.colorScheme.primary),
        _EntryStatus(display),
      ],
    );
  }
}

class _EntryStatus extends StatelessWidget {
  final EntryDisplay display;

  const _EntryStatus(this.display);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    switch (display.entry.status) {
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
  final EntryDisplay display;

  const _EntryInfo(this.display);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AppDateTimeText(display.entry.issuedAt),
        Text(
          display.entry.journal.displayName,
          style: theme.textTheme.bodySmall,
        ),
        if (display.entry.controller?.id == null)
          Text(
            display.entry.controller!.id.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        if (display.hasMutableLabels) AppLabelRow(display.mutableLabels),
      ],
    );
  }
}
