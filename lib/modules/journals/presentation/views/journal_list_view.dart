import 'package:bandha/core/presentation/layouts/app_pager_layout.dart';
import 'package:bandha/modules/journals/presentation/view_models/journal_list_view_model.dart';
import 'package:bandha/modules/journals/presentation/widgets/journal_tile.dart';
import 'package:flutter/material.dart';

class JournalListView extends StatefulWidget {
  const JournalListView({super.key});

  @override
  State<JournalListView> createState() => _JournalListViewState();
}

class _JournalListViewState extends State<JournalListView> {
  JournalListViewModel? vm;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (vm == null) {
      vm = JournalListViewModel.of(context);
      vm?.query();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPagerLayout(
      title: 'Journals',
      valueListenable: vm!.notifier,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final shouldRefresh = await Navigator.pushNamed<bool>(
            context,
            "/journals/new",
          );

          if (shouldRefresh != null && shouldRefresh) {
            vm?.query();
          }
        },
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: vm!.pager.length,
          itemBuilder: (context, index) {
            final journal = vm!.pager[index];
            return JournalTile(journal);
          },
        );
      },
    );
  }
}
