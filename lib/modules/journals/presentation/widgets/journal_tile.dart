import 'package:bandha/core/presentation/widgets/app_dismissible.dart';
import 'package:bandha/core/presentation/widgets/app_money_text.dart';
import 'package:bandha/core/presentation/widgets/app_tile.dart';
import 'package:bandha/modules/journals/presentation/models/journal_display.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class JournalTile extends StatelessWidget {
  final JournalDisplay display;
  final bool readOnly;
  final AsyncCallback? onDelete;

  const JournalTile(
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

    Navigator.pushNamed(context, "/journals/${display.journal.id}/edit");
    return false;
  }

  void handleTap(BuildContext context, JournalDisplay journal) {
    Navigator.pushNamed(
      context,
      readOnly
          ? "/journals/${display.journal.id}/detail"
          : "/journals/${display.journal.id}/entries",
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppDismissible(
      key: Key(display.journal.id),
      dismissible: true,
      confirmDismiss: (DismissDirection direction) {
        return handleDismiss(context, direction);
      },
      child: AppTile(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(display.journal.name, style: theme.textTheme.titleSmall),
                  Text(
                    display.journal.holderName,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            AppMoneyText(display.journal.balance, useSymbol: false),
          ],
        ),
      ),
    );
  }
}
