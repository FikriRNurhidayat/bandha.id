import 'package:bandha/core/presentation/view_models/list_view_model.dart';
import 'package:bandha/core/presentation/widgets/app_view_model_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppListViewModelBuilder<T extends ListViewModel> extends StatelessWidget {
  final T Function(BuildContext context) create;
  final Widget Function(BuildContext context, T viewModel) builder;

  const AppListViewModelBuilder({
    super.key,
    required this.create,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AppViewModelBuilder(
      key: super.key,
      create: create,
      builder: (context, vm) {
        final theme = Theme.of(context);

        if (vm.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (vm.isError) {
          if (kDebugMode) {
            print(vm.error);
            print(vm.stackTrace);
          }

          return ListView(
            children: [
              ListTile(
                dense: true,
                title: Text(
                  vm.error.runtimeType.toString(),
                  style: theme.textTheme.titleSmall,
                ),
                subtitle: Text(vm.error.toString()),
              ),
            ],
          );
        }

        if (vm.isEmpty) {
          return ListView(
            children: [
              ListTile(
                dense: true,
                title: Text("Nihil", style: theme.textTheme.titleSmall),
                subtitle: Text("No information is available to display."),
              ),
            ],
          );
        }

        return builder(context, vm);
      },
    );
  }
}
