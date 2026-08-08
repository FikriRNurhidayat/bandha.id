import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_models/async_pager_view_model.dart';
import 'package:bandha/modules/assets/application/use_cases/destroy_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/query_assets.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/presentation/models/asset_display.dart';
import 'package:flutter/widgets.dart';

class AssetListViewModel extends AsyncPagerViewModel<Asset, AssetDisplay> {
  @override
  final QueryAssets queryEntities;

  final DestroyAsset destroyAsset;

  AssetListViewModel({required this.queryEntities, required this.destroyAsset});

  factory AssetListViewModel.fromContainer(DependencyContainer c) {
    return AssetListViewModel(
      queryEntities: c.get<QueryAssets>(),
      destroyAsset: c.get<DestroyAsset>(),
    );
  }

  factory AssetListViewModel.of(BuildContext context) {
    final c = DependencyInjector.of(context);
    return AssetListViewModel.fromContainer(c);
  }

  @override
  AssetDisplay model(Asset entity) => AssetDisplay.of(entity);

  Future<void> destroy(AssetDisplay display) async {
    await execute((pager) async {
      final destroyAssetParams = DestroyAssetParams(display.asset.id);
      await destroyAsset.execute(destroyAssetParams);
      return init();
    });
  }
}
