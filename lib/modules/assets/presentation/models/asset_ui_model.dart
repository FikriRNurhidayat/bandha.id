import 'package:bandha/modules/assets/domain/entities/asset.dart';

class AssetUiModel {
  final Asset asset;

  Object? error;
  bool isError = false;
  bool isDeleted = false;
  bool isLoading = false;

  AssetUiModel(this.asset);

  static List<AssetUiModel> fromAssetList(List<Asset> assets) {
    return assets.map((asset) => AssetUiModel(asset)).toList();
  }

  factory AssetUiModel.fromAsset(Asset asset) {
    return AssetUiModel(asset);
  }
}
