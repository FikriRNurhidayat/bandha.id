import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/modules/entries/shared/presentation/views/controllable_entry_list_view.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/presentation/widgets/journal_tile.dart';
import 'package:flutter/widgets.dart';

class JournalEntryListView extends StatelessWidget {
  final String id;

  const JournalEntryListView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return ControllableEntryListView<Journal>.builder(
      context,
      id: id,
      title: 'Journal entries',
      tileBuilder: JournalTile.builder,
      dataFilterBuilder: (journal) => {"journal_id_eq": journal.id},
      onTileTap: (context, item) async {
        await Navigator.pushNamed<Draft<Journal>>(
          context,
          "/journals/${item.entity.id}/detail",
        );
      },
    );
  }
}
