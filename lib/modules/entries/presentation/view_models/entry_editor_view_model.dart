import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/view_models/async_editor_view_model.dart';
import 'package:bandha/core/types/timestamp.dart';
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
    final labelIds = (formData["labels"] as Iterable? ?? const [])
        .map((i) => i.id as String)
        .toList();

    final entry = await createEntry.execute(
      note: formData["note"],
      amount: formData["amount"],
      status: formData["status"].first,
      categoryId: formData["category"].first.id,
      journalId: formData["journal"].first.id,
      issuedAt: formData["timestamp"].dateTime,
      labelIds: labelIds,
    );
    return Draft<Entry>(entry);
  }

  @override
  Future<Draft<Entry>> onUpdate() async {
    final labelIds = (formData["labels"] as Iterable? ?? const [])
        .map((i) => i.id as String)
        .toList();

    final entry = await updateEntry.execute(
      id!,
      note: formData["note"],
      amount: formData["amount"],
      status: formData["status"].first,
      categoryId: formData["category"].first.id,
      journalId: formData["journal"].first.id,
      issuedAt: formData["timestamp"].dateTime,
      labelIds: labelIds,
    );
    return Draft<Entry>(entry);
  }

  @override
  Future<Draft<Entry>> fill(Draft<Entry> draft) async {
    formData["note"] = draft.entity.note;
    formData["amount"] = draft.entity.amount;
    formData["status"] = [draft.entity.status];
    formData["category"] = [draft.entity.category];
    formData["journal"] = [draft.entity.journal];
    formData["timestamp"] = Timestamp.specific(draft.entity.issuedAt);
    formData["labels"] = draft.entity.labels;

    return draft;
  }
}
