import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/modules/assets/domain/entities/asset.dart';
import 'package:bandha/modules/journals/application/use_cases/create_journal.dart';
import 'package:bandha/modules/journals/application/use_cases/update_journal.dart';
import 'package:bandha/modules/journals/domain/entities/journal.dart';
import 'package:flutter/material.dart';

class JournalEditorViewModel extends AsyncEditorViewModel<Journal> {
  final CreateJournal createJournal;
  final UpdateJournal updateJournal;

  @override
  final GetEntity<Journal> getEntity;

  JournalEditorViewModel._({
    required this.createJournal,
    required this.updateJournal,
    required this.getEntity,
  });

  factory JournalEditorViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<JournalEditorViewModel>();
  }

  factory JournalEditorViewModel.build(DependencyContainer c) {
    return JournalEditorViewModel._(
      createJournal: c.get<CreateJournal>(),
      updateJournal: c.get<UpdateJournal>(),
      getEntity: c.get<GetEntity<Journal>>(),
    );
  }

  @override
  Future<Draft<Journal>> onCreate() async {
    final journal = await createJournal.execute(
      name: formData["name"]!,
      holderName: formData["holderName"]!,
      balance: formData["balance"]!,
      assetId: formData["asset"]!.entity.id,
    );
    return Draft<Journal>(journal);
  }

  @override
  Future<Draft<Journal>> onUpdate() async {
    final journal = await updateJournal.execute(
      id!,
      name: formData["name"]!,
      holderName: formData["holderName"]!,
      balance: formData["balance"]!,
    );
    return Draft<Journal>(journal);
  }

  @override
  Future<Draft<Journal>> fill(Draft<Journal> draft) async {
    formData["name"] = draft.entity.name;
    formData["holderName"] = draft.entity.holderName;
    formData["balance"] = draft.entity.balance;
    formData["asset"] = Item<Asset>(draft.entity.asset);
    return draft;
  }
}
