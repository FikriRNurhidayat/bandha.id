import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_dismissible.dart';
import 'package:bandha/core/presentation/widgets/texts/x_money_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_tile.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class JournalTile extends StatelessWidget {
  final Item<Journal> item;
  final bool readOnly;
  final AsyncCallback? onDelete;

  const JournalTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.onDelete,
  });

  factory JournalTile.builder(Item<Journal> item, {AsyncCallback? onDelete}) {
    return JournalTile(item, onDelete: onDelete);
  }

  factory JournalTile.readonlyBuilder(Item<Journal> item, {AsyncCallback? onDelete}) {
    return JournalTile(item, readOnly: true);
  }

  Future<bool?> handleDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      await onDelete?.call();
      return true;
    }

    Navigator.pushNamed<Draft<Journal>>(
      context,
      "/journals/${item.entity.id}/edit",
    );
    return false;
  }

  void handleTap(BuildContext context) async {
    if (readOnly) {
      await Navigator.pushNamed<Draft<Journal>>(
        context,
        "/journals/${item.entity.id}/detail",
      );

      return;
    }

    Navigator.pushNamed(context, "/journals/${item.entity.id}/entries");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              XMoneyText(item.entity.balance, useSymbol: false),
            ],
          ),
        ),
      ),
    );
  }
}
