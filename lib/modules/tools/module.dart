import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/modules/tools/application/use_cases/backup_ledger.dart';
import 'package:bandha/modules/tools/application/use_cases/reset_ledger.dart';
import 'package:bandha/modules/tools/application/use_cases/restore_ledger.dart';
import 'package:bandha/modules/tools/presentation/view_models/tool_list_view_model.dart';

class ToolModule extends Module {
  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<ResetLedger>(ResetLedger.build(c));
    c.registerSingleton<BackupLedger>(BackupLedger.build(c));
    c.registerSingleton<RestoreLedger>(RestoreLedger.build(c));
    c.registerFactory<ToolListViewModel>(ToolListViewModel.build);
  }
}
