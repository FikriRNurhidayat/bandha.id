import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class QueryAssets extends QueryEntities<Asset> {
  final AssetRepository assetRepository;

  QueryAssets({required this.assetRepository}) : super(assetRepository);

  @override
  Repository<Asset> get repository => assetRepository;

  factory QueryAssets.build(DependencyContainer c) {
    return QueryAssets(assetRepository: c.get<AssetRepository>());
  }
}
