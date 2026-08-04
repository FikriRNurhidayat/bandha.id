import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class UpdateAssetParams {
  final String id;
  final String? name;
  final String? code;

  UpdateAssetParams(this.id, {this.name, this.code});
}

class UpdateAsset extends UseCase<UpdateAssetParams, Asset> {
  final AssetRepository assetRepository;
  final UnitOfWork unitOfWork;

  UpdateAsset({required this.assetRepository, required this.unitOfWork});

  factory UpdateAsset.fromContainer(DependencyContainer c) {
    return UpdateAsset(
      assetRepository: c.get<AssetRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  @override
  Future<Asset> execute(UpdateAssetParams params) async {
    return unitOfWork.execute<Asset>(() async {
      final before = await assetRepository.get(params.id);
      final after = before.copyWith(name: params.name, code: params.code);
      await assetRepository.save(after);
      return after;
    });
  }
}
