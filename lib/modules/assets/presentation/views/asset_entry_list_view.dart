import 'package:bandha/modules/assets/presentation/models/asset_display.dart';
import 'package:bandha/modules/assets/presentation/view_models/asset_entry_list_view_model.dart';
import 'package:bandha/modules/assets/presentation/widgets/asset_tile.dart';
import 'package:bandha/modules/entries/presentation/widgets/entry_tile.dart';
import 'package:flutter/material.dart';

class AssetEntryListView extends StatefulWidget {
  final String id;

  const AssetEntryListView({super.key, required this.id});

  @override
  State<AssetEntryListView> createState() => _AssetEntryListViewState();
}

class _AssetEntryListViewState extends State<AssetEntryListView> {
  AssetEntryListViewModel? vm;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();

    if (vm == null) {
      vm = AssetEntryListViewModel.of(context);
      vm?.init(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Asset detail", style: theme.textTheme.titleMedium),
        automaticallyImplyLeading: false,
      ),
      body: _AssetView(vm!),
    );
  }
}

class _AssetView extends StatelessWidget {
  final AssetEntryListViewModel vm;

  const _AssetView(this.vm);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<AsyncSnapshot<AssetDisplay>>(
      valueListenable: vm.notifier,
      builder: (context, snapshot, child) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ListView(
            children: [
              ListTile(
                dense: true,
                title: Text(
                  snapshot.error.runtimeType.toString(),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  snapshot.stackTrace?.toString() ??
                      "Stack trace is not available.",
                ),
              ),
            ],
          );
        }

        if (!snapshot.hasData) {
          return ListView(
            children: [
              ListTile(
                dense: true,
                title: Text("Nihil", style: theme.textTheme.titleSmall),
                subtitle: Text("No data available."),
              ),
            ],
          );
        }

        return Column(
          children: [
            AssetTile(snapshot.requireData, readOnly: true),
            Expanded(child: _EntryListView(vm)),
          ],
        );
      },
    );
  }
}

class _EntryListView extends StatefulWidget {
  final AssetEntryListViewModel vm;

  const _EntryListView(this.vm);

  @override
  State<_EntryListView> createState() => _EntryListViewState();
}

class _EntryListViewState extends State<_EntryListView> {
  AssetEntryListViewModel? vm;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();

    if (vm == null) {
      vm = widget.vm;
      vm!.entryProvider.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: widget.vm.entryProvider.notifier,
      builder: (context, snapshot, child) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ListView(
            children: [
              ListTile(
                dense: true,
                title: Text(
                  snapshot.error.runtimeType.toString(),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(
                  snapshot.stackTrace?.toString() ??
                      "Stack trace is not available.",
                ),
              ),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.requireData.isEmpty) {
          return ListView(
            children: [
              ListTile(
                dense: true,
                title: Text("Nihil", style: theme.textTheme.titleSmall),
                subtitle: Text("No data available."),
              ),
            ],
          );
        }

        return ListView.builder(
          itemCount: snapshot.requireData.length,
          itemBuilder: (context, index) {
            final entry = snapshot.requireData[index];
            return EntryTile(entry);
          },
        );
      },
    );
  }
}
