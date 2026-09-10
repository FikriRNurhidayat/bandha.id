import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/layouts/pager_layout.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AsyncListTileBuilder<E extends Entity> =
    Widget Function(
      Item<E>, {
      bool? readOnly,
      bool? minified,
      AsyncCallback? onTap,
      AsyncCallback? onLongPress,
    });

class AsyncListView<E extends Entity> extends StatefulWidget {
  const AsyncListView._({
    super.key,
    required this.vmResolver,
    required this.name,
    required this.tileBuilder,
    this.onTileTap,
  });

  final String name;
  final AsyncListTileBuilder<E> tileBuilder;
  final AsyncListViewModel<E> Function() vmResolver;
  final Future<void> Function(BuildContext context, Item<E> item)? onTileTap;

  factory AsyncListView.builder(
    BuildContext context, {
    required String name,
    required AsyncListTileBuilder<E> tileBuilder,
    Future<void> Function(BuildContext context, Item<E> item)? onTileTap,
  }) {
    return AsyncListView<E>._(
      vmResolver: () =>
          DependencyInjector.of(context).get<AsyncListViewModel<E>>(),
      name: name,
      tileBuilder: tileBuilder,
      onTileTap: onTileTap,
    );
  }

  @override
  State<AsyncListView<E>> createState() => _AsyncListViewState<E>();
}

class _AsyncListViewState<E extends Entity> extends State<AsyncListView<E>> {
  late final resources = widget.name.toLowerCase();
  late final vm = widget.vmResolver();

  @override
  initState() {
    super.initState();
    vm.query();
  }

  @override
  dispose() {
    super.dispose();
    vm.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagerLayout(
      title: widget.name,
      valueListenable: vm.notifier,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final shouldRefresh = await Navigator.pushNamed<Draft<E>>(
            context,
            "/$resources/new",
          );

          if (shouldRefresh != null) {
            vm.query();
          }
        },
      ),
      appBarBuilder: (context) {
        final theme = Theme.of(context);

        List<Widget> actions;
        Widget? title;
        Widget? leading;
        double? leadingWidth;

        if (vm.hasCandidates) {
          actions = [
            IconButton(
              icon: Icon(
                Icons.delete_outlined,
                size: theme.textTheme.titleMedium?.fontSize,
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  fullscreenDialog: true,
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      icon: Icon(Icons.delete_outlined),
                      title: Text(
                        "Delete ${widget.name}",
                        style: theme.textTheme.titleSmall,
                      ),
                      content: Column(
                        spacing: 16,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "The following ${widget.name.toLowerCase()} will be removed. Action cannot be undone.",
                            style: theme.textTheme.bodySmall,
                          ),
                          ListView.separated(
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16),
                            shrinkWrap: true,
                            itemCount: vm.candidates.length,
                            itemBuilder: (context, index) {
                              final candidate = vm.candidates.toList()[index];
                              return widget.tileBuilder(
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
                          onPressed: () async {
                            for (final candidate in vm.candidates) {
                              if (!context.mounted) {
                                continue;
                              }

                              await vm.destroy(candidate);
                            }

                            await vm.removeItems(vm.candidates);
                            await vm.resetSelection();

                            if (!context.mounted) return;
                            Navigator.of(context).pop(false);
                          },
                          child: Text("Delete"),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == null || !confirmed) return;
                for (final candidate in vm.candidates) {
                  if (!context.mounted) {
                    continue;
                  }

                  await vm.destroy(candidate);
                }

                await vm.resetSelection();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                size: theme.textTheme.titleMedium?.fontSize,
              ),
              onPressed: () async {
                for (final candidate in vm.candidates) {
                  if (!context.mounted) {
                    continue;
                  }

                  final draft = await Navigator.pushNamed<Draft<E>>(
                    context,
                    "/$resources/${candidate.entity.id}/edit",
                  );

                  if (draft != null) {
                    await vm.updateItem(Item<E>(draft.entity));
                  }
                }

                await vm.resetSelection();
              },
            ),
          ];
          leadingWidth = 96;
          leading = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: theme.textTheme.titleMedium?.fontSize,
                ),
                onPressed: () {
                  vm.resetSelection();
                },
              ),
              Text(
                vm.candidates.length.toString(),
                style: theme.textTheme.titleMedium,
              ),
            ],
          );
        } else {
          title = Text(widget.name, style: theme.textTheme.titleMedium);
          actions = [];
        }

        return AppBar(
          leadingWidth: leadingWidth,
          leading: leading,
          title: title,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0.0,
          actions: actions,
          backgroundColor: Theme.of(context).colorScheme.surface,
        );
      },
      builder: (context) {
        return ListView.builder(
          itemCount: vm.pager.length,
          itemBuilder: (context, index) {
            final item = vm.pager[index];
            return widget.tileBuilder(
              item,
              onTap: () async {
                if (!vm.hasCandidates) {
                  if (widget.onTileTap == null) {
                    await Navigator.pushNamed<Draft<E>>(
                      context,
                      "/$resources/${item.entity.id}/detail",
                    );
                  } else {
                    await widget.onTileTap?.call(context, item);
                  }

                  await vm.refreshItem(item);

                  return;
                }

                if (item.readOnly) {
                  return;
                }

                if (item.isSelected) {
                  await vm.deselectAll([item]);
                  return;
                }

                await vm.selectAll([item]);
              },
              onLongPress: !item.isSelected && !item.readOnly
                  ? () async {
                      vm.selectAll([item]);
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}
