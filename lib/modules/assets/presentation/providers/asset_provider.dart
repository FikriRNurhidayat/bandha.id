import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_models/async_pager_view_model.dart';
import 'package:bandha/modules/assets/application/use_cases/query_assets.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/presentation/models/asset_display.dart';
import 'package:flutter/widgets.dart';

class AssetProvider extends AsyncPagerViewModel<Asset, AssetDisplay> {
  @override
  final QueryAssets queryEntities;

  AssetProvider({required this.queryEntities});

  factory AssetProvider.of(BuildContext context) {
    return DependencyInjector.of(context).get<AssetProvider>();
  }

  factory AssetProvider.fromContainer(DependencyContainer c) {
    return AssetProvider(queryEntities: c.get<QueryAssets>());
  }

  @override
  AssetDisplay model(Asset asset) {
    return AssetDisplay.of(asset);
  }
}
