import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class DestroyAsset extends DestroyEntity<Asset> {
  DestroyAsset(super.repository);

  factory DestroyAsset.build(DependencyContainer c) {
    return DestroyAsset(c.get<AssetRepository>());
  }
}
