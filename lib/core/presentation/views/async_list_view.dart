import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/layouts/x_pager_layout.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AsyncListTileBuilder<E extends Entity> =
    Widget Function(Item<E>, {AsyncCallback? onDelete, AsyncCallback? onEdit});

class AsyncListView<E extends Entity> extends StatefulWidget {
  final String name;
  final AsyncListTileBuilder<E> tileBuilder;
  final AsyncListViewModel<E> Function() vmResolver;

  const AsyncListView._({
    super.key,
    required this.vmResolver,
    required this.name,
    required this.tileBuilder,
  });

  factory AsyncListView.builder(
    BuildContext context, {
    required String name,
    required AsyncListTileBuilder<E> tileBuilder,
  }) {
    return AsyncListView<E>._(
      vmResolver: () =>
          DependencyInjector.of(context).get<AsyncListViewModel<E>>(),
      name: name,
      tileBuilder: tileBuilder,
    );
  }

  @override
  State<AsyncListView<E>> createState() => _AsyncListViewState<E>();
}

class _AsyncListViewState<E extends Entity> extends State<AsyncListView<E>> {
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
    return XPagerLayout(
      title: widget.name,
      valueListenable: vm.notifier,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final shouldRefresh = await Navigator.pushNamed<Draft<E>>(
            context,
            "/${widget.name.toLowerCase()}/new",
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
            final item = vm.pager[index];
            return widget.tileBuilder(
              item,
              onEdit: () async {
                await vm.query();
              },
              onDelete: () async {
                await vm.destroy(item);
              },
            );
          },
        );
      },
    );
  }
}
