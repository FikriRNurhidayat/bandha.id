import 'package:bandha/core/data/repository_impl.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/assets/data/data_sources/asset_local_storage.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/ports/asset_reader.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';

class AssetRepositoryImpl extends RepositoryImpl<Asset>
    implements AssetRepository, AssetReader {
  @override
  final AssetLocalStorage localStorage;

  AssetRepositoryImpl(this.localStorage);

  factory AssetRepositoryImpl.fromContainer(DependencyContainer c) {
    return AssetRepositoryImpl(c.get<AssetLocalStorage>());
  }

  @override
  Future<void> balance(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> incrementBalance(String id, double delta) {
    throw UnimplementedError();
  }
}
