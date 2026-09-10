import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/layouts/tile_layout.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/types/tile_builder.dart';
import 'package:bandha/core/presentation/view_models/async_tile_view_model.dart';
import 'package:flutter/material.dart';

class AsyncTileView<E extends Entity> extends StatefulWidget {
  final String id;
  final String title;
  final AsyncTileViewModel<E> Function() vmResolver;
  final TileBuilder<E> tileBuilder;
  final Widget? Function(BuildContext context, Item<E>? entity)? fabBuilder;
  final Widget Function(BuildContext context, Item<E> entity) builder;
  final Future<void> Function(BuildContext, Item<E>)? onTileTap;

  const AsyncTileView._({
    super.key,
    required this.id,
    required this.title,
    required this.vmResolver,
    required this.tileBuilder,
    required this.builder,
    this.fabBuilder,
    this.onTileTap,
  });

  factory AsyncTileView.builder(
    BuildContext context, {
    required String id,
    required String title,
    required TileBuilder<E> tileBuilder,
    required Widget Function(BuildContext context, Item<E> entity) builder,
    Widget? Function(BuildContext context, Item<E>? entity)? fabBuilder,
    Future<void> Function(BuildContext, Item<E>)? onTileTap,
  }) {
    final c = DependencyInjector.of(context);
    return AsyncTileView<E>._(
      vmResolver: () => c.get<AsyncTileViewModel<E>>(),
      id: id,
      title: title,
      tileBuilder: tileBuilder,
      fabBuilder: fabBuilder,
      builder: builder,
      onTileTap: onTileTap,
    );
  }

  @override
  State<AsyncTileView<E>> createState() => _AsyncTileViewState<E>();
}

class _AsyncTileViewState<E extends Entity> extends State<AsyncTileView<E>> {
  late final vm = widget.vmResolver();

  @override
  initState() {
    vm.query(widget.id);
    super.initState();
  }

  @override
  dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TileLayout(
      title: widget.title,
      notifier: vm.notifier,
      fabBuilder: widget.fabBuilder != null
          ? (context) => widget.fabBuilder?.call(context, vm.data)
          : null,
      builder: (BuildContext context) {
        return Column(
          spacing: 16,
          children: [
            widget.tileBuilder(
              vm.requireData,
              onTap: () async =>
                  widget.onTileTap?.call(context, vm.requireData),
            ),
            widget.builder(context, vm.requireData),
          ],
        );
      },
    );
  }
}
