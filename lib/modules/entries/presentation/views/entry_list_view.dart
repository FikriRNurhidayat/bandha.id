import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/views/async_list_view.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/widgets/entry_tile.dart';
import 'package:bandha/modules/funds/domain/entities/fund.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/transfers/domain/entities/transfer.dart';
import 'package:flutter/widgets.dart';

class EntryListView extends StatelessWidget {
  const EntryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncListView<Entry>.builder(
      context,
      name: 'Entries',
      tileBuilder: EntryTile.builder,
      onTileTap: (context, item) async {
        if (item.entity.controller != null) {
          final controllerType = item.entity.controller!.type;
          final entityId = item.entity.controller!.id;

          switch (controllerType) {
            case "Fund":
              await Navigator.pushNamed<Draft<Fund>>(
                context,
                "/funds/$entityId/entries",
              );
              return;
            case "Journal":
              await Navigator.pushNamed<Draft<Journal>>(
                context,
                "/journals/$entityId/entries",
              );
              return;
            case "Transfer":
              await Navigator.pushNamed<Draft<Transfer>>(
                context,
                "/transfers/$entityId/entries",
              );
              return;
            default:
              return;
          }
        }

        await Navigator.pushNamed<Draft<Entry>>(
          context,
          "/entries/${item.entity.id}/detail",
        );
      },
    );
  }
}
