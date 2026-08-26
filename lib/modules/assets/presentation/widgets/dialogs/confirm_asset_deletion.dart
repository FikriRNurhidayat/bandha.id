import 'package:bandha/core/presentation/widgets/dialogs/dialog.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:flutter/material.dart';

Future<bool?> confirmAssetDeletion(
  BuildContext context,
  Asset asset,
  Future<void> Function(BuildContext context) onConfirm,
) async {
  return showAppDialog(
    context,
    title: "Delete asset",
    content: "Asset ${asset.name} will be deleted. Are you sure?",
    onConfirm: onConfirm,
  );
}
