import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/modules/tools/application/use_cases/reset_ledger.dart';
import 'package:bandha/modules/tools/presentation/models/tool_ui_model.dart';
import 'package:flutter/widgets.dart';

class ToolListViewModel extends ChangeNotifier {
  final ResetLedger _resetLedger;

  ToolListViewModel(this._resetLedger);

  factory ToolListViewModel.fromContainer(DependencyContainer c) {
    return ToolListViewModel(c.get<ResetLedger>());
  }

  factory ToolListViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<ToolListViewModel>();
  }

  List<ToolUiModel> get items {
    return [
      ToolUiModel(
        title: "Reset ledger",
        subtitle: "Remove existing ledger.",
        onTap: () async {
          await _resetLedger.call();
        },
      ),
    ];
  }
}
