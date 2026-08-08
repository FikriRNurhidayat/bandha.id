import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_models/async_view_model.dart';
import 'package:bandha/modules/assets/application/use_cases/create_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/get_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/update_asset.dart';
import 'package:bandha/modules/assets/presentation/models/asset_display.dart';
import 'package:flutter/widgets.dart';

class AssetEditorViewModel extends AsyncViewModel<AssetDisplay> {
  late final bool readOnly;
  late final bool isEditing;
  late final String? id;

  final CreateAsset createAsset;
  final UpdateAsset updateAsset;
  final GetAsset getAsset;

  AssetEditorViewModel({
    required this.createAsset,
    required this.updateAsset,
    required this.getAsset,
  });

  factory AssetEditorViewModel.fromContainer(DependencyContainer c) {
    return AssetEditorViewModel(
      createAsset: c.get<CreateAsset>(),
      updateAsset: c.get<UpdateAsset>(),
      getAsset: c.get<GetAsset>(),
    );
  }

  factory AssetEditorViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<AssetEditorViewModel>();
  }

  @override
  final notifier = ValueNotifier<AsyncSnapshot<AssetDisplay>>(
    AsyncSnapshot.nothing(),
  );

  final nameNotifier = ValueNotifier<String?>(null);
  final codeNotifier = ValueNotifier<String?>(null);
  final balanceNotifier = ValueNotifier<double?>(null);

  String? get name => nameNotifier.value;
  String? get code => codeNotifier.value;
  double? get balance => balanceNotifier.value;

  Future<void> init({String? id, required bool readOnly}) async {
    this.readOnly = readOnly;
    isEditing = id != null;
    this.id = id;

    if (id == null) return;

    await execute((i) async {
      final params = GetEntityParams(id);
      final asset = await getAsset.execute(params);

      nameNotifier.value = asset.name;
      codeNotifier.value = asset.code;
      balanceNotifier.value = asset.balance;

      return AssetDisplay.of(asset);
    });
  }

  Future<void> save() async {
    if (readOnly) return;

    if (isEditing) {
      return await execute((_) async {
        final params = UpdateAssetParams(id!, name: name, code: code);
        final asset = await updateAsset.execute(params);

        nameNotifier.value = asset.name;
        codeNotifier.value = asset.code;
        balanceNotifier.value = asset.balance;

        return AssetDisplay.of(asset);
      });
    }

    return await execute((_) async {
      final params = CreateAssetParams(name: name!, code: code!);
      final asset = await createAsset.execute(params);

      nameNotifier.value = asset.name;
      codeNotifier.value = asset.code;
      balanceNotifier.value = asset.balance;

      return AssetDisplay.of(asset);
    });
  }
}
