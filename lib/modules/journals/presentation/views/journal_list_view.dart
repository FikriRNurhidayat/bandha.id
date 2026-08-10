import 'package:bandha/core/presentation/views/async_list_view.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:bandha/modules/journals/presentation/widgets/journal_tile.dart';
import 'package:flutter/widgets.dart';

class JournalListView extends StatelessWidget {
  const JournalListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncListView<Journal>.builder(
      context,
      name: 'Journals',
      tileBuilder: JournalTile.builder,
    );
  }
}
