import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/texts/x_date_time_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_dismissible.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_tile.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TransferTile extends StatelessWidget {
  final Item<Transfer> item;
  final bool readOnly;
  final AsyncCallback? onDelete;

  const TransferTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.onDelete,
  });

  factory TransferTile.builder(Item<Transfer> item, {AsyncCallback? onDelete}) {
    return TransferTile(item, onDelete: onDelete);
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
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [XDateTimeText(item.entity.issuedAt)],
          ),
        ),
      ),
    );
  }

  Future<bool?> handleDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      // return await confirmTransferDeletion(context, item.entity, (context) async {
      //   await onDelete?.call();
      // });
    }

    Navigator.pushNamed<Draft<Transfer>>(
      context,
      "/transfers/${item.entity.id}/edit",
    );
    return false;
  }

  void handleTap(BuildContext context) {
    Navigator.pushNamed(context, "/transfers/${item.entity.id}/detail");
    // if (readOnly) {
    //   Navigator.pushNamed(context, "/transfers/${item.entity.id}/detail");
    //   return;
    // }

    // Navigator.pushNamed(context, "/transfers/${item.entity.id}/entries");
  }
}
