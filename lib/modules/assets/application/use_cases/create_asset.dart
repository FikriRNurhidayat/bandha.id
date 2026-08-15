import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class CreateAsset {
  final AssetRepository assetRepository;

  factory CreateAsset.build(DependencyContainer c) {
    return CreateAsset(assetRepository: c.get<AssetRepository>());
  }

  CreateAsset({required this.assetRepository});

  Future<Asset> execute({required String name, required String code}) async {
    final asset = Asset.create(name: name, code: code);
    await assetRepository.save(asset);
    return asset;
  }
}
