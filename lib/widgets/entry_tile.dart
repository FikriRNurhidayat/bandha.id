import 'package:banda/entity/entry.dart';
import 'package:banda/helpers/date_helper.dart';
import 'package:banda/helpers/dialog_helper.dart';
import 'package:banda/types/controller_type.dart';
import 'package:banda/widgets/money_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EntryTile extends StatelessWidget {
  final Entry entry;
  final bool readOnly;

  final dateFormatter = DateFormat("yyyy/MM/dd");

  EntryTile(this.entry, {super.key, this.readOnly = false});

  String getDate() {
    return DateHelper.formatSimpleDate(entry.issuedAt);
  }

  String getTime() {
    return DateHelper.formatTime(TimeOfDay.fromDateTime(entry.issuedAt));
  }

  Widget getEntryStatusLabel(BuildContext context) {
    final theme = Theme.of(context);
    switch (entry.status) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(entry.id),
      background: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      secondaryBackground: Container(
        color: theme.colorScheme.surfaceContainer,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      direction: (entry.readonly || readOnly)
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          return confirmEntryDeletion(context, entry);
        }

        Navigator.pushNamed(context, "/entries/${entry.id}/edit");
        return false;
      },
      child: ListTile(
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(text: "app://bandha.id/entries/${entry.id}/detail"),
          );
        },
        onTap: () {
          if (readOnly) {
            return;
          }

          switch (entry.controller?.type) {
            case ControllerType.fund:
              Navigator.pushNamed(
                context,
                "/funds/${entry.controller!.id}/entries",
              );
              break;
            case ControllerType.transfer:
              Navigator.pushNamed(
                context,
                "/transfers/${entry.controller!.id}/entries",
              );
              break;
            case ControllerType.bill:
              Navigator.pushNamed(
                context,
                "/bills/${entry.controller!.id}/detail",
              );
              break;
            case ControllerType.loan:
              Navigator.pushNamed(
                context,
                "/loans/${entry.controller!.id}/payments",
              );
              break;
            default:
              Navigator.pushNamed(context, "/entries/${entry.id}/detail");
          }
        },
        dense: true,
        enableFeedback: !entry.readonly,
        title: Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(entry.category.name, style: theme.textTheme.titleSmall),
            if (entry.readonly)
              Icon(Icons.lock, size: 8, color: theme.colorScheme.primary),
            getEntryStatusLabel(context),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              entry.account.displayName(),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            Text(
              "${getDate()} at ${getTime()}",
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              entry.note,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              spacing: 8,
              children: [
                ...entry.labels
                    .take(2)
                    .map(
                      (label) => Text(
                        label.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                if (entry.labels.length > 2)
                  Icon(
                    Icons.more_horiz,
                    size: 8,
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ],
        ),
        trailing: MoneyText(entry.amount),
      ),
    );
  }
}
