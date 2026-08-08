import 'package:bandha/core/presentation/widgets/app_dismissible.dart';
import 'package:bandha/core/presentation/widgets/app_money_text.dart';
import 'package:bandha/core/presentation/widgets/app_tile.dart';
import 'package:bandha/modules/assets/presentation/models/asset_display.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AssetTile extends StatelessWidget {
  final AssetDisplay model;
  final bool readOnly;
  final AsyncCallback? onDelete;

  const AssetTile(
    this.model, {
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

    Navigator.pushNamed<AssetDisplay>(context, "/assets/${model.asset.id}/edit");
    return false;
  }

  void handleTap(BuildContext context, AssetDisplay model) {
    if (readOnly) {
      Navigator.pushNamed(context, "/assets/${model.asset.id}/detail");
      return;
    }

    Navigator.pushNamed(context, "/assets/${model.asset.id}/entries");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppDismissible(
      key: Key(model.asset.id),
      dismissible: true,
      confirmDismiss: (DismissDirection direction) {
        return handleDismiss(context, direction);
      },
      child: AppTile(
        onTap: () {
          handleTap(context, model);
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
                    Text(model.asset.name, style: theme.textTheme.titleSmall),
                    Text(model.asset.code, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [AppMoneyText(model.asset.balance, useSymbol: false)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
