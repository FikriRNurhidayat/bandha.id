import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/presentation/types/x_tile_builder.dart';
import 'package:bandha/core/presentation/views/async_tile_view.dart';
import 'package:bandha/modules/entries/presentation/widgets/controllable_entry_list.dart';
import 'package:flutter/material.dart';

class ControllableEntryListView<C extends Controllable> extends StatefulWidget {
  final String id;
  final String title;
  final XTileBuilder<C> tileBuilder;
  final bool readOnly;

  const ControllableEntryListView({
    super.key,
    required this.id,
    required this.title,
    required this.tileBuilder,
    this.readOnly = true,
  });

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
          readOnly: widget.readOnly,
          controllable: item.entity,
        ),
      ),
    );
  }
}
