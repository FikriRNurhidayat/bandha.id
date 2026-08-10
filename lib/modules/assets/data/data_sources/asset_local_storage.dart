import 'package:bandha/core/data/data_sources/local_storage.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';

abstract class AssetLocalStorage extends LocalStorage<Asset> {
  Future<void> balance(String id);
  Future<void> incrementBalance(String id, double delta);
}
