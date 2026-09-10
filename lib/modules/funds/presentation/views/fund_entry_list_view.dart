import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/shared/presentation/view_models/controllable_entry_list_view_model.dart';
import 'package:bandha/modules/entries/shared/presentation/views/controllable_entry_list_view.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/funds/presentation/view_models/fund_entry_list_view_model.dart';
import 'package:bandha/modules/funds/presentation/widgets/fund_tile.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class FundEntryListView extends StatelessWidget {
  final String id;

  const FundEntryListView({super.key, required this.id});

  Widget? fabBuilder(
    BuildContext context,
    Item<Fund>? item,
    ControllableEntryListViewModel<Fund> vm,
  ) {
    if (item == null ||
        item.entity.status.isReleased ||
        item.entity.balance >= item.entity.amount) {
      return null;
    }

    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async {
        final shouldRefresh = await Navigator.pushNamed<Draft<Entry>>(
          context,
          "/funds/${item.entity.id}/entries/new",
        );

        if (shouldRefresh != null) {
          vm.initialize();
        }
      },
    );
  }

  AppBar appBarBuilder(
    BuildContext context,
    ControllableEntryListViewState<Fund> state,
  ) {
    final vm = state.vm as FundEntryListViewModel;
    final theme = Theme.of(context);
    List<Widget>? actions;

    if (state.vm.candidates.isNotEmpty && !state.effectiveReadOnly) {
      actions = [
        if (state.widget.destroyable) state.deleteButton,
        if (state.widget.editable) state.editButton,
      ];
    }

    if (state.vm.candidates.isEmpty && vm.controller.hasData) {
      actions = [
        if (!vm.controller.requireData.entity.status.isReleased)
          IconButton(
            onPressed: () async {
              await vm.disburse();
            },
            icon: Icon(
              Symbols.arrow_cool_down,
              size: theme.textTheme.titleMedium?.fontSize,
            ),
          ),
      ];
    }

    return AppBar(
      title: Text("Fund entries", style: theme.textTheme.titleMedium),
      scrolledUnderElevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ControllableEntryListView<Fund>.builder(
      context,
      id: id,
      title: 'Fund entries',
      readOnlyResolver: (context, item) => item.entity.status.isReleased,
      appBarBuilder: appBarBuilder,
      fabBuilder: fabBuilder,
      dataFilterBuilder: (fund) => fund.dataFilter,
      destroyable: true,
      editable: false,
      tileBuilder: FundTile.builder,
      onTileTap: (context, item) async {
        await Navigator.pushNamed<Draft<Fund>>(
          context,
          "/funds/${item.entity.id}/detail",
        );
      },
      onShow: (context, fund, entry) async => Navigator.pushNamed<Draft<Entry>>(
        context,
        "/funds/${fund.entity.id}/entries/${entry.entity.id}/detail",
      ),
      onEdit: (context, fund, entry) async => Navigator.pushNamed<Draft<Entry>>(
        context,
        "/funds/${fund.entity.id}/entries/${entry.entity.id}/edit",
      ),
    );
  }
}
