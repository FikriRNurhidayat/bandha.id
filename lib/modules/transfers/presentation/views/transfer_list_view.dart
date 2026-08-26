import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/views/async_list_view.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:bandha/modules/transfers/presentation/widgets/transfer_tile.dart';
import 'package:flutter/widgets.dart';

class TransferListView extends StatelessWidget {
  const TransferListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncListView<Transfer>.builder(
      context,
      name: 'Transfers',
      tileBuilder: TransferTile.builder,
      onTileTap: (context, item) async {
        await Navigator.pushNamed<Draft<Transfer>>(
          context,
          "/transfers/${item.entity.id}/entries",
        );
      },
    );
  }
}
