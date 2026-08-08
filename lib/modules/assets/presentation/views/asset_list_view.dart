import 'package:bandha/core/presentation/layouts/app_pager_layout.dart';
import 'package:bandha/modules/assets/presentation/models/asset_display.dart';
import 'package:bandha/modules/assets/presentation/view_models/asset_list_view_model.dart';
import 'package:bandha/modules/assets/presentation/widgets/asset_tile.dart';
import 'package:flutter/material.dart';

class AssetListView extends StatefulWidget {
  const AssetListView({super.key});

  @override
  State<AssetListView> createState() => _AssetListViewState();
}

class _AssetListViewState extends State<AssetListView> {
  late final AssetListViewModel vm;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    vm = AssetListViewModel.of(context);
    vm.query();
  }

  @override
  dispose() {
    super.dispose();
    vm.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPagerLayout(
      title: "Assets",
      valueListenable: vm.notifier,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final shouldRefresh = await Navigator.pushNamed<AssetDisplay>(
            context,
            "/assets/new",
          );

          if (shouldRefresh != null) {
            vm.query();
          }
        },
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: vm.pager.length,
          itemBuilder: (context, index) {
            final asset = vm.pager[index];
            return AssetTile(
              asset,
              onDelete: () async {
                await vm.destroy(asset);
              },
            );
          },
        );
      },
    );
  }
}
