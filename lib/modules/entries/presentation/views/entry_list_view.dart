import 'package:bandha/core/presentation/views/async_list_view.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:bandha/modules/entries/presentation/widgets/entry_tile.dart';
import 'package:flutter/widgets.dart';

class EntryListView extends StatelessWidget {
  const EntryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncListView<Entry>.builder(
      context,
      name: 'Entries',
      tileBuilder: EntryTile.builder,
    );
  }
}
