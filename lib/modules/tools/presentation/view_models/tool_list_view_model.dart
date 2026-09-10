import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_models/list_view_model.dart';
import 'package:bandha/modules/tools/application/use_cases/backup_ledger.dart';
import 'package:bandha/modules/tools/application/use_cases/reset_ledger.dart';
import 'package:bandha/modules/tools/application/use_cases/restore_ledger.dart';
import 'package:bandha/modules/tools/presentation/models/tool_menu.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ToolListViewModel extends ListViewModel<ToolMenu> {
  ToolListViewModel({
    required this.resetLedger,
    required this.backupLedger,
    required this.restoreLedger,
  }) : notifier = ValueNotifier<List<ToolMenu>>([]);

  @override
  final ValueNotifier<List<ToolMenu>> notifier;

  final ResetLedger resetLedger;
  final BackupLedger backupLedger;
  final RestoreLedger restoreLedger;

  Future<void> Function(BuildContext) execute(
    Future<void> Function(BuildContext) block,
  ) {
    return (context) async {
      final theme = Theme.of(context);

      try {
        await block.call(context);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Icon(
                Symbols.thumb_up,
                size: theme.textTheme.bodySmall?.fontSize,
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (error, stackTrace) {
        debugPrint(error.toString());
        debugPrint(stackTrace.toString());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Icon(Symbols.thumb_down),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    };
  }

  Future<void> initialize() async {
    notifier.value = [
      ToolMenu(
        title: "Reset ledger",
        subtitle: "Reset current ledger to a clean slate.",
        use: execute((context) async {
          await resetLedger.execute();
        }),
      ),
      ToolMenu(
        title: "Backup ledger",
        subtitle: "Backup current ledger.",
        use: execute((context) async {
          await backupLedger.execute();
        }),
      ),
      ToolMenu(
        title: "Restore ledger",
        subtitle:
            "This will replace current ledger with the given ledger database file.",
        use: execute((context) async {
          await restoreLedger.execute();
        }),
      ),
    ];
  }

  factory ToolListViewModel.build(DependencyContainer c) {
    return ToolListViewModel(
      resetLedger: c.get<ResetLedger>(),
      backupLedger: c.get<BackupLedger>(),
      restoreLedger: c.get<RestoreLedger>(),
    );
  }

  factory ToolListViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<ToolListViewModel>();
  }

  List<ToolMenu> get menu => notifier.value;
}
