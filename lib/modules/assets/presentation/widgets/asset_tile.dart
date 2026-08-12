import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_dismissible.dart';
import 'package:bandha/core/presentation/widgets/texts/x_money_text.dart';
import 'package:bandha/core/presentation/widgets/tiles/x_tile.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/presentation/widgets/dialogs/confirm_asset_deletion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AssetTile extends StatelessWidget {
  final Item<Asset> item;
  final bool readOnly;
  final AsyncCallback? onDelete;
  final AsyncCallback? onEdit;

  const AssetTile(
    this.item, {
    super.key,
    this.readOnly = false,
    this.onDelete,
    this.onEdit,
  });

  factory AssetTile.builder(
    Item<Asset> item, {
    AsyncCallback? onDelete,
    AsyncCallback? onEdit,
  }) {
    return AssetTile(item, onDelete: onDelete, onEdit: onEdit);
  }

  Future<bool?> handleDismiss(
    BuildContext context,
    DismissDirection direction,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      return await confirmAssetDeletion(context, item.entity, (context) async {
        await onDelete?.call();
      });
    }

    final asset = await Navigator.pushNamed<Draft<Asset>>(
      context,
      "/assets/${item.entity.id}/edit",
    );

    if (asset != null) {
      await onEdit?.call();
    }

    return false;
  }

  void handleTap(BuildContext context) {
    Navigator.pushNamed(context, "/assets/${item.entity.id}/detail");
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
        child: Container(
          padding: EdgeInsets.all(16),
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
                    Text(item.entity.code, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [XMoneyText(item.entity.balance, useSymbol: false)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
