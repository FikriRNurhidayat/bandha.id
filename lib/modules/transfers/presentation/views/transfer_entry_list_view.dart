import 'package:bandha/modules/entries/shared/presentation/views/controllable_entry_list_view.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/presentation/widgets/transfer_tile.dart';
import 'package:flutter/widgets.dart';

class TransferEntryListView extends StatelessWidget {
  final String id;

  const TransferEntryListView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return ControllableEntryListView<Transfer>(
      id: id,
      title: 'Transfer entries',
      tileBuilder: TransferTile.builder,
      dataFilterBuilder: (transfer) => transfer.dataFilter,
    );
  }
}
