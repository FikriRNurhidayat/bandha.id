import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/modules/assets/application/event_handlers/update_asset_balance_on_entry_created.dart';
import 'package:bandha/modules/assets/application/event_handlers/update_asset_balance_on_entry_destroyed.dart';
import 'package:bandha/modules/assets/application/event_handlers/update_asset_balance_on_entry_updated.dart';
import 'package:bandha/modules/assets/application/use_cases/create_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/destroy_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/get_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/query_assets.dart';
import 'package:bandha/modules/assets/application/use_cases/update_asset.dart';
import 'package:bandha/modules/assets/data/data_sources/asset_local_storage.dart';
import 'package:bandha/modules/assets/data/data_sources/asset_sqlite_storage.dart';
import 'package:bandha/modules/assets/data/repositories/asset_repository_impl.dart';
import 'package:bandha/modules/assets/domain/ports/asset_reader.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';
import 'package:bandha/modules/assets/presentation/view_models/asset_form_view_model.dart';
import 'package:bandha/modules/assets/presentation/view_models/asset_list_view_model.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';

class AssetModule extends Module {
  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<AssetSqliteStorage>(
      AssetSqliteStorage.fromContainer(c),
    );

    c.registerSingleton<AssetLocalStorage>(c.get<AssetSqliteStorage>());

    final assetRepositoryImpl = AssetRepositoryImpl.fromContainer(c);
    c.registerSingleton<AssetRepositoryImpl>(assetRepositoryImpl);
    c.registerSingleton<AssetRepository>(assetRepositoryImpl);
    c.registerSingleton<AssetReader>(assetRepositoryImpl);
  }

  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<CreateAsset>(CreateAsset.fromContainer(c));
    c.registerSingleton<UpdateAsset>(UpdateAsset.fromContainer(c));
    c.registerSingleton<GetAsset>(GetAsset.fromContainer(c));
    c.registerSingleton<DestroyAsset>(DestroyAsset.fromContainer(c));
    c.registerSingleton<QueryAssets>(QueryAssets.fromContainer(c));

    c.registerFactory<AssetListViewModel>(AssetListViewModel.fromContainer);
    c.registerFactory<AssetFormViewModel>(AssetFormViewModel.fromContainer);
  }

  @override
  Future<void> event(DependencyContainer c, DomainEventPublisher e) async {
    e.register<EntryCreated>(UpdateAssetBalanceOnEntryCreated.fromContainer(c));
    e.register<EntryDestroyed>(
      UpdateAssetBalanceOnEntryDestroyed.fromContainer(c),
    );
    e.register<EntryUpdated>(UpdateAssetBalanceOnEntryUpdated.fromContainer(c));
  }
}
