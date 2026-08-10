import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/modules/entries/application/use_cases/create_entry.dart';
import 'package:bandha/modules/entries/application/use_cases/update_entry.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/material.dart';

class EntryEditorViewModel extends AsyncEditorViewModel<Entry> {
  final CreateEntry createEntry;
  final UpdateEntry updateEntry;

  @override
  final GetEntity<Entry> getEntity;

  EntryEditorViewModel._({
    required this.createEntry,
    required this.updateEntry,
    required this.getEntity,
  });

  factory EntryEditorViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<EntryEditorViewModel>();
  }

  factory EntryEditorViewModel.build(DependencyContainer c) {
    return EntryEditorViewModel._(
      createEntry: c.get<CreateEntry>(),
      updateEntry: c.get<UpdateEntry>(),
      getEntity: c.get<GetEntity<Entry>>(),
    );
  }

  @override
  Future<Draft<Entry>> onCreate() async {
    final entry = await createEntry.execute(
      note: formData["note"]!,
      amount: formData["amount"]!,
      status: formData["status"]!,
      categoryId: formData["category"]!.entity.id,
      journalId: formData["journal"]!.entity.id,
      issuedAt: formData["issuedAt"]!,
      labelIds: formData["labels"]?.map((i) => i.entity.id),
    );
    return Draft<Entry>(entry);
  }

  @override
  Future<Draft<Entry>> onUpdate() async {
    final entry = await updateEntry.execute(
      id!,
      note: formData["note"]!,
      amount: formData["amount"]!,
      status: formData["status"]!,
      categoryId: formData["category"]!.entity.id,
      journalId: formData["journal"]!.entity.id,
      issuedAt: formData["issuedAt"]!,
      labelIds: formData["labels"]?.map((i) => i.entity.id),
    );
    return Draft<Entry>(entry);
  }

  @override
  Future<Draft<Entry>> fill(Draft<Entry> draft) async {
    return draft;
  }
}
