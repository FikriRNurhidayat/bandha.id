import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_models/list_view_model.dart';
import 'package:bandha/modules/tools/application/use_cases/reset_ledger.dart';
import 'package:bandha/modules/tools/presentation/models/tool_ui_model.dart';
import 'package:flutter/widgets.dart';

class ToolListViewModel extends ListViewModel<ToolUiModel> {
  @override
  final ValueNotifier<List<ToolUiModel>> notifier;

  final ResetLedger resetLedger;

  ToolListViewModel({required this.resetLedger})
    : notifier = ValueNotifier<List<ToolUiModel>>([
        ToolUiModel(
          title: "Reset ledger",
          subtitle: "Reset current ledger to a clean slate.",
          use: (context) async {
            await resetLedger.execute();
          },
        ),
        ToolUiModel(
          title: "Editor sandbox",
          subtitle: "Open editor sandbox",
          use: (context) async {
            Navigator.of(context).pushNamed("/tools/editor");
          },
        ),
      ]);

  factory ToolListViewModel.build(DependencyContainer c) {
    return ToolListViewModel(resetLedger: c.get<ResetLedger>());
  }

  factory ToolListViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<ToolListViewModel>();
  }

  List<ToolUiModel> get menu => notifier.value;
}
