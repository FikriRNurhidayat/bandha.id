import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_models/async_view_model.dart';
import 'package:bandha/modules/assets/application/use_cases/get_asset.dart';
import 'package:bandha/modules/assets/presentation/models/asset_display.dart';
import 'package:bandha/modules/entries/presentation/providers/entry_provider.dart';
import 'package:flutter/widgets.dart';

class AssetEntryListViewModel extends AsyncViewModel<AssetDisplay> {
  final GetAsset getAsset;
  final EntryProvider entryProvider;

  AssetEntryListViewModel({
    required this.getAsset,
    required this.entryProvider,
  });

  factory AssetEntryListViewModel.fromContainer(DependencyContainer c) {
    return AssetEntryListViewModel(
      getAsset: c.get<GetAsset>(),
      entryProvider: c.get<EntryProvider>(),
    );
  }

  factory AssetEntryListViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<AssetEntryListViewModel>();
  }

  @override
  void dispose() {
    super.dispose();
    entryProvider.dispose();
  }

  @override
  final notifier = ValueNotifier<AsyncSnapshot<AssetDisplay>>(
    AsyncSnapshot.nothing(),
  );

  Future<void> init(String id) => execute((assetDisplay) async {
    final assetParams = GetEntityParams(id);
    final asset = await getAsset.execute(assetParams);
    return AssetDisplay.of(asset);
  });
}
