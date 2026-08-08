import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/view_models/async_view_model.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/assets/presentation/providers/asset_provider.dart';
import 'package:bandha/modules/journals/application/use_cases/create_journal.dart';
import 'package:bandha/modules/journals/application/use_cases/get_journal.dart';
import 'package:bandha/modules/journals/application/use_cases/update_journal.dart';
import 'package:bandha/modules/journals/presentation/models/journal_display.dart';
import 'package:flutter/widgets.dart';

class JournalEditorViewModel extends AsyncViewModel<JournalDisplay> {
  late final bool readOnly;
  late final bool isEditing;
  late final String? id;

  final CreateJournal createJournal;
  final UpdateJournal updateJournal;
  final GetJournal getJournal;
  final AssetProvider assetProvider;

  JournalEditorViewModel({
    required this.createJournal,
    required this.updateJournal,
    required this.getJournal,
    required this.assetProvider,
  });

  factory JournalEditorViewModel.fromContainer(DependencyContainer c) {
    return JournalEditorViewModel(
      createJournal: c.get<CreateJournal>(),
      updateJournal: c.get<UpdateJournal>(),
      getJournal: c.get<GetJournal>(),
      assetProvider: c.get<AssetProvider>(),
    );
  }

  factory JournalEditorViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<JournalEditorViewModel>();
  }

  @override
  final notifier = ValueNotifier<AsyncSnapshot<JournalDisplay>>(
    AsyncSnapshot.nothing(),
  );

  final nameNotifier = ValueNotifier<String?>(null);
  final holderNameNotifier = ValueNotifier<String?>(null);
  final balanceNotifier = ValueNotifier<double?>(null);
  final assetNotifier = ValueNotifier<Asset?>(null);

  String? get name => nameNotifier.value;
  String? get holderName => holderNameNotifier.value;
  double? get balance => balanceNotifier.value;
  Asset? get asset => assetNotifier.value;

  Future<void> init({String? id, required bool readOnly}) async {
    this.readOnly = readOnly;
    isEditing = id != null;
    this.id = id;

    if (id == null) return;

    await execute((i) async {
      final params = GetEntityParams(id);
      final journal = await getJournal.execute(params);

      nameNotifier.value = journal.name;
      holderNameNotifier.value = journal.holderName;
      balanceNotifier.value = journal.balance;

      return JournalDisplay.of(journal);
    });
  }

  Future<void> save() async {
    if (readOnly) return;

    if (isEditing) {
      return await execute((_) async {
        final params = UpdateJournalParams(
          id!,
          name: name,
          holderName: holderName,
        );
        final journal = await updateJournal.execute(params);

        nameNotifier.value = journal.name;
        holderNameNotifier.value = journal.holderName;
        balanceNotifier.value = journal.balance;
        assetNotifier.value = journal.asset;

        return JournalDisplay.of(journal);
      });
    }

    return await execute((_) async {
      final params = CreateJournalParams(
        name: name!,
        holderName: holderName!,
        balance: balance!,
        assetId: assetNotifier.value!.id,
      );
      final journal = await createJournal.execute(params);

      nameNotifier.value = journal.name;
      holderNameNotifier.value = journal.holderName;
      balanceNotifier.value = journal.balance;
      assetNotifier.value = journal.asset;

      return JournalDisplay.of(journal);
    });
  }
}
