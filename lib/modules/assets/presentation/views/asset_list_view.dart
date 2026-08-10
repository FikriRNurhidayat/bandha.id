import 'package:bandha/core/presentation/views/async_list_view.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/presentation/widgets/asset_tile.dart';
import 'package:flutter/widgets.dart';

class AssetListView extends StatelessWidget {
  const AssetListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncListView<Asset>.builder(
      context,
      name: 'Assets',
      tileBuilder: AssetTile.builder,
    );
  }
}
