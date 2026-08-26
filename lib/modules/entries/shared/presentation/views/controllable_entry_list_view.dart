import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/domain/types/data_filter.dart';
import 'package:bandha/core/presentation/types/x_tile_builder.dart';
import 'package:bandha/core/presentation/views/async_tile_view.dart';
import 'package:bandha/modules/entries/presentation/widgets/controllable_entry_list.dart';
import 'package:flutter/material.dart';

typedef ControllableDataFilterBuilder<C extends Controllable> =
    DataFilter Function(C);

class ControllableEntryListView<C extends Controllable> extends StatefulWidget {
  const ControllableEntryListView({
    super.key,
    required this.id,
    required this.title,
    required this.tileBuilder,
    this.readOnly = true,
    this.dataFilterBuilder,
  });

  final String id;
  final String title;
  final TileBuilder<C> tileBuilder;
  final bool readOnly;
  final ControllableDataFilterBuilder<C>? dataFilterBuilder;

  @override
  State<ControllableEntryListView<C>> createState() =>
      _ControllableEntryListViewState<C>();
}

class _ControllableEntryListViewState<C extends Controllable>
    extends State<ControllableEntryListView<C>> {
  @override
  Widget build(BuildContext context) {
    return AsyncTileView<C>.builder(
      context,
      id: widget.id,
      title: widget.title,
      tileBuilder: widget.tileBuilder,
      builder: (context, item) => Expanded(
        child: ControllableEntryList.builder(
          context,
          dataFilter:
              widget.dataFilterBuilder?.call(item.entity) ??
              item.entity.dataFilter,
          readOnly: widget.readOnly,
          controllable: item.entity,
        ),
      ),
    );
  }
}
