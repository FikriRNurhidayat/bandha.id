import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/providers/async_list_provider.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/widgets/entry_tile.dart';
import 'package:flutter/material.dart';

class ControllableEntryList extends StatefulWidget {
  const ControllableEntryList._({
    required this.providerResolver,
    required this.readOnly,
    required this.controllable,
    required this.dataFilter,
  });

  final AsyncListProvider<Entry> Function() providerResolver;
  final bool readOnly;
  final Controllable controllable;
  final DataFilter dataFilter;

  factory ControllableEntryList.builder(
    BuildContext context, {
    required bool readOnly,
    required Controllable controllable,
    required DataFilter dataFilter,
  }) {
    final c = DependencyInjector.of(context);
    return ControllableEntryList._(
      providerResolver: () => c.get<AsyncListProvider<Entry>>(),
      readOnly: readOnly,
      controllable: controllable,
      dataFilter: dataFilter,
    );
  }

  @override
  State<ControllableEntryList> createState() => _ControllableEntryListState();
}

class _ControllableEntryListState extends State<ControllableEntryList> {
  late final AsyncListProvider<Entry> provider = widget.providerResolver();

  @override
  initState() {
    super.initState();
    provider.setFilter(widget.dataFilter);
    provider.query();
  }

  @override
  dispose() {
    super.dispose();
    provider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: provider.notifier,
      builder: (context, snapshot, child) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
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
            final item = snapshot.requireData[index];
            return EntryTile(
              item,
              readOnly: true,
              onTap: () async {
                await Navigator.pushNamed<Draft<Entry>>(
                  context,
                  "/entries/${item.entity.id}",
                );
              },
            );
          },
        );
      },
    );
  }
}
