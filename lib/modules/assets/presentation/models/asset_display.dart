import 'package:bandha/modules/assets/domain/entities/asset.dart';

class AssetDisplay {
  final Asset asset;

  AssetDisplay(this.asset);

  factory AssetDisplay.of(Asset asset) {
    return AssetDisplay(asset);
  }
}
