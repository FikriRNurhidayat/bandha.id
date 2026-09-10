import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/types/tile_builder.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/widgets/controllable_entry_list.dart';
import 'package:bandha/modules/entries/presentation/widgets/entry_tile.dart';
import 'package:bandha/modules/entries/shared/presentation/view_models/controllable_entry_list_view_model.dart';
import 'package:flutter/material.dart';

class ControllableEntryListView<C extends Controllable> extends StatefulWidget {
  const ControllableEntryListView({
    super.key,
    required this.id,
    required this.title,
    required this.tileBuilder,
    required this.vmResolver,
    this.appBarBuilder,
    this.dataFilterBuilder,
    this.fabBuilder,
    this.onTileTap,
    this.readOnlyResolver,
    this.readOnly,
    this.destroyable = false,
    this.editable = false,
    this.formatter,
    this.onEdit,
    this.onShow,
  });

  final String id;
  final String title;
  final TileBuilder<C> tileBuilder;
  final bool? readOnly;
  final bool editable;
  final bool destroyable;
  final CELVReadOnlyResolver<C>? readOnlyResolver;
  final CELVAppBarBuilder<C>? appBarBuilder;
  final CELVFabBuilder<C>? fabBuilder;
  final CELVDataFilterBuilder<C>? dataFilterBuilder;
  final CELVTapCallback<C>? onTileTap;
  final CELVRedirectCallback<C>? onShow;
  final CELVRedirectCallback<C>? onEdit;
  final CELVMResolver<C> vmResolver;
  final CELVEntryFormatter? formatter;

  factory ControllableEntryListView.builder(
    BuildContext context, {
    required String id,
    required String title,
    required TileBuilder<C> tileBuilder,
    required CELVDataFilterBuilder<C>? dataFilterBuilder,
    CELVAppBarBuilder<C>? appBarBuilder,
    CELVEntryFormatter? formatter,
    CELVFabBuilder<C>? fabBuilder,
    CELVTapCallback<C>? onTileTap,
    CELVRedirectCallback<C>? onEdit,
    CELVRedirectCallback<C>? onShow,
    CELVReadOnlyResolver<C>? readOnlyResolver,
    bool? readOnly,
    bool destroyable = false,
    bool editable = false,
  }) {
    final c = DependencyInjector.of(context);
    return ControllableEntryListView<C>(
      appBarBuilder: appBarBuilder,
      dataFilterBuilder: dataFilterBuilder,
      destroyable: destroyable,
      editable: editable,
      fabBuilder: fabBuilder,
      formatter: formatter,
      id: id,
      onEdit: onEdit,
      onShow: onShow,
      onTileTap: onTileTap,
      readOnly: readOnly,
      readOnlyResolver: readOnlyResolver,
      tileBuilder: tileBuilder,
      title: title,
      vmResolver: () => c.get<ControllableEntryListViewModel<C>>(),
    );
  }

  @override
  State<ControllableEntryListView<C>> createState() =>
      ControllableEntryListViewState<C>();
}

class ControllableEntryListViewState<C extends Controllable>
    extends State<ControllableEntryListView<C>> {
  late final vm = widget.vmResolver();

  bool get effectiveReadOnly =>
      widget.readOnly ?? widget.readOnlyResolver != null
      ? widget.readOnlyResolver!.call(context, vm.controller.requireData)
      : true;

  @override
  initState() {
    vm
        .withController(widget.id)
        .withDataFilter(widget.dataFilterBuilder)
        .initialize();
    super.initState();
  }

  @override
  dispose() {
    vm.dispose();
    super.dispose();
  }

  Future<void> handleEntryTap(Item<Entry> item) async {
    if (vm.candidates.isNotEmpty) {
      if (item.isSelected) {
        await vm.deselect(item);
      } else {
        await vm.select(item);
      }

      return;
    }

    if (effectiveReadOnly) {
      await Navigator.of(
        context,
      ).pushNamed<Draft<Entry>>("/entries/${item.entity.id}/detail");

      return;
    }

    widget.onShow?.call(context, vm.controller.requireData, item);
  }

  Future<void> handleEntryLongPress(Item<Entry> item) async {
    if (item.isSelected) {
      await vm.deselect(item);
    } else {
      await vm.select(item);
    }
  }

  ThemeData get theme => Theme.of(context);

  Future<void> showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      fullscreenDialog: true,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          icon: Icon(Icons.delete_outlined),
          title: Text(
            "Delete ${C.toString().toLowerCase()} entry",
            style: theme.textTheme.titleSmall,
          ),
          content: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "The following ${C.toString().toLowerCase()} entry will be removed. Action cannot be undone.",
                style: theme.textTheme.bodySmall,
              ),
              ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 16),
                shrinkWrap: true,
                itemCount: vm.candidates.length,
                itemBuilder: (context, index) {
                  final candidate = vm.candidates.toList()[index];
                  return EntryTile(
                    candidate.copyWith(isSelected: false),
                    readOnly: true,
                    minified: true,
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed == null || !confirmed) return;
    for (final candidate in vm.candidates) {
      if (!context.mounted) continue;
      await vm.destroy(candidate);
    }

    await vm.removeAll(vm.candidates);
    await vm.resetSelection();
    await vm.initialize();
  }

  Future<void> handleEditTap() async {
    final items = <Item<Entry>>[];

    for (final candidate in vm.candidates) {
      if (!mounted) {
        continue;
      }

      final draft = widget.onEdit != null
          ? await widget.onEdit?.call(
              context,
              vm.controller.requireData,
              candidate,
            )
          : null;

      final item = draft ?? Draft<Entry>(candidate.entity);
      items.add(Item<Entry>(item.entity));
    }

    await vm.updateAll(items);
    await vm.resetSelection();
    await vm.initialize();
  }

  IconButton get editButton => IconButton(
    icon: Icon(
      Icons.edit_outlined,
      size: theme.textTheme.titleMedium?.fontSize,
    ),
    onPressed: handleEditTap,
  );

  IconButton get deleteButton => IconButton(
    icon: Icon(
      Icons.delete_outlined,
      size: theme.textTheme.titleMedium?.fontSize,
    ),
    onPressed: showDeleteDialog,
  );

  AppBar get defaultAppBar => AppBar(
    title: Text("$C entries", style: theme.textTheme.titleMedium),
    scrolledUnderElevation: 0.0,
    automaticallyImplyLeading: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    actions: [
      if (vm.candidates.isNotEmpty && !effectiveReadOnly && widget.destroyable)
        deleteButton,
      if (vm.candidates.isNotEmpty && !effectiveReadOnly && widget.editable)
        editButton,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final theme = Theme.of(context);
        Widget scaffoldBody;

        switch (vm.controller.connectionState) {
          case ConnectionState.waiting:
            scaffoldBody = SizedBox.shrink();
          case ConnectionState.done when vm.controller.hasError:
            scaffoldBody = ListView(
              children: [
                ListTile(
                  dense: true,
                  title: Text(
                    vm.entries.error.runtimeType.toString(),
                    style: theme.textTheme.titleSmall,
                  ),
                  subtitle: Text(
                    vm.entries.stackTrace?.toString() ??
                        "Stack trace is not available.",
                  ),
                ),
              ],
            );
          default:
            Widget listView;

            switch (vm.entries.connectionState) {
              case ConnectionState.waiting:
                listView = ListView(shrinkWrap: true);
              case ConnectionState.done when vm.entries.hasError:
                listView = ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      dense: true,
                      title: Text(
                        vm.entries.error.runtimeType.toString(),
                        style: theme.textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        vm.entries.stackTrace?.toString() ??
                            "Stack trace is not available.",
                      ),
                    ),
                  ],
                );
              case ConnectionState.done
                  when vm.entries.hasData && vm.entries.requireData.isEmpty:
                listView = ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      dense: true,
                      title: Text("Nihil", style: theme.textTheme.titleSmall),
                      subtitle: Text("No data available."),
                    ),
                  ],
                );
              case ConnectionState.done
                  when vm.entries.hasData && vm.entries.requireData.isNotEmpty:
              default:
                listView = Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: vm.entries.requireData.length,
                    itemBuilder: (context, index) {
                      final i = vm.entries.requireData[index];
                      final item = widget.formatter?.call(i) ?? i;
                      return EntryTile(
                        item,
                        readOnly: effectiveReadOnly,
                        onTap: () async {
                          handleEntryTap(item);
                        },
                        onLongPress: !effectiveReadOnly && vm.candidates.isEmpty
                            ? () async {
                                handleEntryLongPress(item);
                              }
                            : null,
                      );
                    },
                  ),
                );
            }

            scaffoldBody = Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                widget.tileBuilder(
                  vm.controller.requireData,
                  onTap: widget.onTileTap != null
                      ? () async {
                          widget.onTileTap?.call(
                            context,
                            vm.controller.requireData,
                          );
                        }
                      : null,
                ),
                listView,
              ],
            );
        }

        return Scaffold(
          appBar: widget.appBarBuilder?.call(context, this) ?? defaultAppBar,
          body: SafeArea(bottom: true, child: scaffoldBody),
          floatingActionButton: widget.fabBuilder?.call(
            context,
            vm.controller.data,
            vm,
          ),
        );
      },
    );
  }
}

typedef CELVReadOnlyResolver<C extends Controllable> =
    bool Function(BuildContext, Item<C>);

typedef CELVAppBarBuilder<C extends Controllable> =
    PreferredSizeWidget Function(
      BuildContext,
      ControllableEntryListViewState<C>,
    );

typedef CELVMResolver<C extends Controllable> =
    ControllableEntryListViewModel<C> Function();

typedef CELVTapCallback<C extends Controllable> =
    Future<void> Function(BuildContext, Item<C>);

typedef CELVFabBuilder<C extends Controllable> =
    Widget? Function(BuildContext, Item<C>?, ControllableEntryListViewModel<C>);

typedef CELVRedirectCallback<C extends Controllable> =
    Future<Draft<Entry>?> Function(BuildContext, Item<C>, Item<Entry>);
