import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_model.dart';
import 'package:bandha/modules/assets/application/use_cases/create_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/get_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/update_asset.dart';
import 'package:bandha/modules/assets/presentation/models/asset_ui_model.dart';
import 'package:flutter/widgets.dart';

class AssetFormViewModel extends ViewModel {
  final CreateAsset createAsset;
  final UpdateAsset updateAsset;
  final GetAsset _getAsset;

  AssetFormViewModel(this.createAsset, this.updateAsset, this._getAsset);

  factory AssetFormViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<AssetFormViewModel>();
  }

  factory AssetFormViewModel.fromContainer(DependencyContainer c) {
    return AssetFormViewModel(
      c.get<CreateAsset>(),
      c.get<UpdateAsset>(),
      c.get<GetAsset>(),
    );
  }

  final formKey = GlobalKey<FormState>();

  String? name;
  String? code;

  AssetUiModel? _model;
  AssetUiModel? get model => _model;

  Future<void> get(String id) async {
    await execute(() async {
      final asset = await _getAsset.execute(GetEntityParams(id));

      _model = AssetUiModel.fromAsset(asset);

      print("ASSET: $asset");
      print("ASSET.NAME: ${asset.name}");
      print("ASSET.CODE: ${asset.code}");

      name = asset.name;
      code = asset.code;
    });
  }

  Future<void> create() async {
    if (formKey.currentState == null) return;
    if (!formKey.currentState!.validate()) return;

    formKey.currentState?.save();

    await execute(() async {
      await createAsset.execute(CreateAssetParams(name: name!, code: code!));
    });
  }

  Future<void> update({String? name, String? code}) async {
    if (_model == null) {
      return;
    }

    await execute(() async {
      await updateAsset.execute(
        UpdateAssetParams(_model!.asset.id, name: name, code: code),
      );
    });
  }
}
