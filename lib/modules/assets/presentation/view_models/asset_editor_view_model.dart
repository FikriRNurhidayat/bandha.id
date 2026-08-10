import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/modules/assets/application/use_cases/create_asset.dart';
import 'package:bandha/modules/assets/application/use_cases/update_asset.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:flutter/material.dart';

class AssetEditorViewModel extends AsyncEditorViewModel<Asset> {
  final CreateAsset createAsset;
  final UpdateAsset updateAsset;

  @override
  final GetEntity<Asset> getEntity;

  AssetEditorViewModel._({
    required this.createAsset,
    required this.updateAsset,
    required this.getEntity,
  });

  factory AssetEditorViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<AssetEditorViewModel>();
  }

  factory AssetEditorViewModel.build(DependencyContainer c) {
    return AssetEditorViewModel._(
      createAsset: c.get<CreateAsset>(),
      updateAsset: c.get<UpdateAsset>(),
      getEntity: c.get<GetEntity<Asset>>(),
    );
  }

  @override
  Future<Draft<Asset>> onCreate() async {
    final asset = await createAsset.execute(
      name: formData["name"]!,
      code: formData["code"]!,
    );
    return Draft<Asset>(asset);
  }

  @override
  Future<Draft<Asset>> onUpdate() async {
    final asset = await updateAsset.execute(
      id!,
      name: formData["name"]!,
      code: formData["code"]!,
    );
    return Draft<Asset>(asset);
  }

  @override
  Future<Draft<Asset>> fill(Draft<Asset> draft) async {
    formData["name"] = draft.entity.name;
    formData["code"] = draft.entity.code;
    return draft;
  }
}
