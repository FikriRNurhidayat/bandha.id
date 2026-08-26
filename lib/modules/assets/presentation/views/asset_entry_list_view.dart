import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/presentation/widgets/asset_tile.dart';
import 'package:bandha/modules/entries/shared/presentation/views/controllable_entry_list_view.dart';
import 'package:flutter/material.dart';

class AssetEntryListView extends StatelessWidget {
  const AssetEntryListView({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return ControllableEntryListView<Asset>(
      id: id,
      title: 'Asset entries',
      tileBuilder: (Item<Asset> item) => AssetTile.builder(item),
      dataFilterBuilder: (asset) => {"journal.asset_id_eq": asset.id},
    );
  }
}
