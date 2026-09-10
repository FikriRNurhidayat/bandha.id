import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/presentation/widgets/asset_tile.dart';
import 'package:bandha/modules/entries/shared/presentation/views/controllable_entry_list_view.dart';
import 'package:flutter/material.dart';

class AssetEntryListView extends StatelessWidget {
  const AssetEntryListView({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return ControllableEntryListView<Asset>.builder(
      context,
      id: id,
      title: 'Asset entries',
      tileBuilder: AssetTile.builder,
      dataFilterBuilder: (asset) => {"journal.asset_id_eq": asset.id},
      onTileTap: (context, item) async {
        await Navigator.pushNamed<Draft<Asset>>(
          context,
          "/assets/${item.entity.id}/detail",
        );
      },
    );
  }
}
