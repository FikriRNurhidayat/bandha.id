import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/presentation/providers/async_list_provider.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/widgets/entry_tile.dart';
import 'package:flutter/material.dart';

class ControllableEntryList extends StatefulWidget {
  final AsyncListProvider<Entry> Function() providerResolver;
  final bool readOnly;
  final Controllable controllable;

  const ControllableEntryList._({
    required this.providerResolver,
    required this.readOnly,
    required this.controllable,
  });

  factory ControllableEntryList.builder(
    BuildContext context, {
    required bool readOnly,
    required Controllable controllable,
  }) {
    final c = DependencyInjector.of(context);
    return ControllableEntryList._(
      providerResolver: () => c.get<AsyncListProvider<Entry>>(),
      readOnly: readOnly,
      controllable: controllable,
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
            final item = snapshot.requireData[index];
            return EntryTile(item, readOnly: true);
          },
        );
      },
    );
  }
}
