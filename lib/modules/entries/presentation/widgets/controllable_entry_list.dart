import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/providers/async_pager_provider.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/widgets/entry_tile.dart';
import 'package:flutter/material.dart';

typedef CELVEntryFormatter = Item<Entry> Function(Item<Entry>);

class ControllableEntryList extends StatefulWidget {
  const ControllableEntryList({
    super.key,
    required this.readOnly,
    required this.controllable,
    required this.dataFilter,
    this.provider,
    this.providerResolver,
    this.formatter,
  });

  final AsyncPagerProvider<Entry> Function()? providerResolver;
  final AsyncPagerProvider<Entry>? provider;
  final bool readOnly;
  final Controllable controllable;
  final DataFilter dataFilter;
  final CELVEntryFormatter? formatter;

  factory ControllableEntryList.builder(
    BuildContext context, {
    required bool readOnly,
    required Controllable controllable,
    required DataFilter dataFilter,
    AsyncPagerProvider<Entry>? provider,
    CELVEntryFormatter? formatter,
  }) {
    final c = DependencyInjector.of(context);
    return ControllableEntryList(
      providerResolver: provider == null
          ? () => c.get<AsyncPagerProvider<Entry>>()
          : null,
      provider: provider,
      formatter: formatter,
      readOnly: readOnly,
      controllable: controllable,
      dataFilter: dataFilter,
    );
  }

  @override
  State<ControllableEntryList> createState() => _ControllableEntryListState();
}

class _ControllableEntryListState extends State<ControllableEntryList> {
  AsyncPagerProvider<Entry>? provider;

  late final effectiveProvider =
      (widget.provider ?? (provider ??= widget.providerResolver?.call()))!;

  final scrollController = ScrollController();

  @override
  initState() {
    effectiveProvider
        .setFormatter(widget.formatter)
        .setFilter(widget.dataFilter)
        .query();
    scrollController.addListener(handleScroll);
    super.initState();
  }

  @override
  dispose() {
    scrollController.removeListener(handleScroll);
    provider?.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> handleScroll() async {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent) {
      await handleNext();
    }
  }

  Future<void> handleNext() async {
    await provider?.next();
  }

  Future<void> handleRefresh() async {
    await provider?.query();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: effectiveProvider.notifier,
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
          controller: scrollController,
          itemCount: snapshot.requireData.length,
          itemBuilder: (context, index) {
            final item = snapshot.requireData[index];

            return EntryTile(
              widget.formatter?.call(item) ?? item,
              readOnly: widget.readOnly,
              onTap: () async {
                await Navigator.pushNamed<Draft<Entry>>(
                  context,
                  "/entries/${item.entity.id}/detail",
                );
              },
            );
          },
        );
      },
    );
  }
}
