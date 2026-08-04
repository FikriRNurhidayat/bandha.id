import 'package:bandha/core/presentation/widgets/app_view_model_builder.dart';
import 'package:bandha/modules/tools/presentation/view_models/tool_list_view_model.dart';
import 'package:flutter/material.dart';

class ToolListView extends StatelessWidget {
  const ToolListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Tools", style: theme.textTheme.titleMedium),
        automaticallyImplyLeading: false,
      ),
      body: AppViewModelBuilder(
        create: (context) {
          return ToolListViewModel.of(context);
        },
        builder: (context, viewModel) {
          return ListView.builder(
            itemCount: viewModel.items.length,
            itemBuilder: (context, i) {
              final tool = viewModel.items[i];
              return ListTile(
                title: Text(tool.title, style: theme.textTheme.titleSmall),
                subtitle: Text(tool.subtitle, style: theme.textTheme.bodySmall),
                onTap: tool.onTap,
              );
            },
          );
        },
      ),
    );
  }
}
