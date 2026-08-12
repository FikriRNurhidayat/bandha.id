import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_dismissible.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_tile.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FundTile extends StatelessWidget {
  final Item<Fund> item;
  final bool readOnly;
  final AsyncCallback? onDelete;
  final AsyncCallback? onEdit;

  const FundTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.onDelete,
    this.onEdit,
  });

  factory FundTile.builder(
    Item<Fund> item, {
    AsyncCallback? onDelete,
    AsyncCallback? onEdit,
  }) {
    return FundTile(item, onDelete: onDelete, onEdit: onEdit);
  }

  Future<bool?> handleDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      // return await confirmFundDeletion(context, item.entity, (context) async {
      //   await onDelete?.call();
      // });
    }

    final fund = await Navigator.pushNamed<Draft<Fund>>(
      context,
      "/funds/${item.entity.id}/edit",
    );
    if (fund != null) {
      await onEdit?.call();
    }
    return false;
  }

  void handleTap(BuildContext context) {
    Navigator.pushNamed(context, "/funds/${item.entity.id}/detail");
    // if (readOnly) {
    //   Navigator.pushNamed(context, "/funds/${item.entity.id}/detail");
    //   return;
    // }

    // Navigator.pushNamed(context, "/funds/${item.entity.id}/entries");
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
            children: [],
          ),
        ),
      ),
    );
  }
}
