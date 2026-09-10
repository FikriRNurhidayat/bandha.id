import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/core/domain/events/domain_event_publisher.dart';
import 'package:bandha/core/presentation/providers/async_select_provider.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:bandha/core/presentation/view_models/async_tile_view_model.dart';
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
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/domain/ports/asset_reader.dart';
import 'package:bandha/modules/assets/domain/repositories/asset_repository.dart';
import 'package:bandha/modules/assets/presentation/view_models/asset_editor_view_model.dart';
import 'package:bandha/modules/entries/domain/events/entry_created.dart';
import 'package:bandha/modules/entries/domain/events/entry_destroyed.dart';
import 'package:bandha/modules/entries/domain/events/entry_updated.dart';
import 'package:bandha/modules/entries/shared/presentation/view_models/controllable_entry_list_view_model.dart';

class AssetModule extends Module {
  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<AssetSqliteStorage>(AssetSqliteStorage.build(c));
    c.registerSingleton<AssetLocalStorage>(c.get<AssetSqliteStorage>());

    final assetRepositoryImpl = AssetRepositoryImpl.build(c);
    c.registerSingleton<AssetRepositoryImpl>(assetRepositoryImpl);
    c.registerSingleton<AssetRepository>(assetRepositoryImpl);
    c.registerSingleton<AssetReader>(assetRepositoryImpl);
  }

  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<CreateAsset>(CreateAsset.build(c));
    c.registerSingleton<UpdateAsset>(UpdateAsset.build(c));
    c.registerSingleton<GetEntity<Asset>>(GetAsset.build(c));
    c.registerSingleton<DestroyEntity<Asset>>(DestroyAsset.build(c));
    c.registerSingleton<QueryEntities<Asset>>(QueryAssets.build(c));
    c.registerFactory<AsyncListViewModel<Asset>>(
      AsyncListViewModel<Asset>.build,
    );
    c.registerFactory<AsyncEditorViewModel<Asset>>(AssetEditorViewModel.build);
    c.registerFactory<AsyncSelectProvider<Asset>>(
      AsyncSelectProvider<Asset>.build,
    );
    c.registerFactory<AsyncTileViewModel<Asset>>(
      AsyncTileViewModel<Asset>.build,
    );
    c.registerFactory<ControllableEntryListViewModel<Asset>>(
      ControllableEntryListViewModel<Asset>.build,
    );
  }

  @override
  Future<void> event(DependencyContainer c, DomainEventPublisher e) async {
    e.register<EntryCreated>(UpdateAssetBalanceOnEntryCreated.build(c));
    e.register<EntryDestroyed>(UpdateAssetBalanceOnEntryDestroyed.build(c));
    e.register<EntryUpdated>(UpdateAssetBalanceOnEntryUpdated.build(c));
  }
}
