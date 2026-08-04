import 'package:bandha/core/presentation/widgets/app_list_view_model_builder.dart';
import 'package:bandha/modules/assets/presentation/models/asset_ui_model.dart';
import 'package:bandha/modules/assets/presentation/view_models/asset_list_view_model.dart';
import 'package:bandha/modules/assets/presentation/widgets/asset_tile.dart';
import 'package:flutter/material.dart';

class AssetListView extends StatelessWidget {
  const AssetListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = AssetListViewModel.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Assets", style: theme.textTheme.titleMedium),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final ok = await Navigator.pushNamed<bool>(context, "/assets/new");
          if (ok != null && ok) {
            vm.query();
          }
        },
      ),
      body: AppListViewModelBuilder<AssetListViewModel>(
        create: (context) {
          vm.query();
          return vm;
        },
        builder: (context, vm) {
          final assets = vm.hits;
          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (BuildContext context, int index) {
              final AssetUiModel asset = assets[index];
              return AssetTile(
                asset,
                onDelete: () {
                  vm.destroy(asset);
                },
              );
            },
          );
        },
      ),
    );
  }
}
