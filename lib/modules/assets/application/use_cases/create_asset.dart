import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';
import 'package:flutter/foundation.dart';

class CreateAssetParams {
  final String name;
  final String code;

  CreateAssetParams({required this.name, required this.code});
}

class CreateAsset extends UseCase<CreateAssetParams, Asset> {
  final AssetRepository assetRepository;

  factory CreateAsset.fromContainer(DependencyContainer c) {
    return CreateAsset(assetRepository: c.get<AssetRepository>());
  }

  CreateAsset({required this.assetRepository});

  @override
  Future<Asset> execute(CreateAssetParams params) async {
    if (kDebugMode) {
      print("CREATE ASSET EXECUTED");
    }

    final asset = Asset.create(name: params.name, code: params.code);
    await assetRepository.save(asset);
    return asset;
  }
}
