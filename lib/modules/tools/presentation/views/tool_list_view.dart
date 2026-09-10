import 'package:bandha/core/presentation/layouts/x_list_layout.dart';
import 'package:bandha/modules/tools/presentation/view_models/tool_list_view_model.dart';
import 'package:flutter/material.dart';

class ToolListView extends StatefulWidget {
  const ToolListView({super.key});

  @override
  State<ToolListView> createState() => ToolListViewState();
}

class ToolListViewState extends State<ToolListView> {
  ToolListViewModel? vm;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (vm == null) {
      vm = ToolListViewModel.of(context);
      vm!.initialize();
    }
  }

  @override
  dispose() {
    super.dispose();
    vm?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListLayout(
      title: "Tools",
      valueListenable: vm!.notifier,
      builder: (context) {
        return ListView.builder(
          itemCount: vm!.menu.length,
          itemBuilder: (context, index) {
            final menu = vm!.menu[index];
            return ListTile(
              title: Text(menu.title, style: theme.textTheme.titleSmall),
              subtitle: Text(menu.subtitle, style: theme.textTheme.bodySmall),
              onTap: () async {
                await menu.use(context);
              },
            );
          },
        );
      },
    );
  }
}
