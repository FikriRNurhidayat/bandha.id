import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';

abstract class AssetRepository extends Repository<Asset> {
  Future<void> balance(String id);
  Future<void> incrementBalance(String id, double delta);
}
