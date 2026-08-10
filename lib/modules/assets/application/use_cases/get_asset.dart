import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class GetAsset extends GetEntity<Asset> {
  final AssetRepository assetRepository;

  GetAsset({required this.assetRepository}) : super(assetRepository);

  @override
  Repository<Asset> get repository => assetRepository;

  factory GetAsset.build(DependencyContainer c) {
    return GetAsset(assetRepository: c.get<AssetRepository>());
  }
}
