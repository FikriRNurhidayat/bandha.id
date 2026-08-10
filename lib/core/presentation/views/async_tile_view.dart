import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/layouts/x_tile_layout.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/types/x_tile_builder.dart';
import 'package:bandha/core/presentation/view_models/async_tile_view_model.dart';
import 'package:flutter/material.dart';

class AsyncTileView<E extends Entity> extends StatefulWidget {
  final String id;
  final String title;
  final AsyncTileViewModel<E> Function() vmResolver;
  final XTileBuilder<E> tileBuilder;
  final Widget Function(BuildContext context, Item<E> entity) builder;

  const AsyncTileView._({
    super.key,
    required this.id,
    required this.title,
    required this.vmResolver,
    required this.tileBuilder,
    required this.builder,
  });

  factory AsyncTileView.builder(
    BuildContext context, {
    required String id,
    required String title,
    required XTileBuilder<E> tileBuilder,
    required Widget Function(BuildContext context, Item<E> entity) builder,
  }) {
    final c = DependencyInjector.of(context);
    return AsyncTileView<E>._(
      vmResolver: () => c.get<AsyncTileViewModel<E>>(),
      id: id,
      title: title,
      tileBuilder: tileBuilder,
      builder: builder,
    );
  }

  @override
  State<AsyncTileView<E>> createState() => _AsyncTileViewState<E>();
}

class _AsyncTileViewState<E extends Entity> extends State<AsyncTileView<E>> {
  late final vm = widget.vmResolver();

  @override
  initState() {
    super.initState();
    vm.query(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return XTileLayout(
      title: widget.title,
      notifier: vm.notifier,
      builder: (BuildContext context) {
        return Column(
          spacing: 16,
          children: [
            widget.tileBuilder(vm.requireData),
            widget.builder(context, vm.requireData),
          ],
        );
      },
    );
  }
}
