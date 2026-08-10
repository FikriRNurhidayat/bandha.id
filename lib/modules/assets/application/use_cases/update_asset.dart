import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class UpdateAsset {
  final AssetRepository assetRepository;
  final UnitOfWork unitOfWork;

  UpdateAsset({required this.assetRepository, required this.unitOfWork});

  factory UpdateAsset.build(DependencyContainer c) {
    return UpdateAsset(
      assetRepository: c.get<AssetRepository>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  Future<Asset> execute(String id, {String? name, String? code}) async {
    return unitOfWork.execute<Asset>(() async {
      final before = await assetRepository.get(id);
      final after = before.copyWith(name: name, code: code);
      await assetRepository.save(after);
      return after;
    });
  }
}
