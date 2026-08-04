import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class DestroyAssetParams {
  final String id;

  DestroyAssetParams(this.id);
}

class DestroyAsset extends UseCase<DestroyAssetParams, void> {
  final AssetRepository assetRepository;
  final UnitOfWork unitOfWork;

  DestroyAsset({required this.assetRepository, required this.unitOfWork});

  factory DestroyAsset.fromContainer(DependencyContainer c) {
    return DestroyAsset(
      assetRepository: c.get<AssetRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  @override
  Future<void> execute(DestroyAssetParams params) async {
    return unitOfWork.execute(() async {
      final asset = await assetRepository.get(params.id);
      await assetRepository.destroy(asset);
    });
  }
}
