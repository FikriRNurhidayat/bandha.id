import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/domain/entities/controllable.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/modules/entries/domain/entities/entry.dart';
import 'package:flutter/widgets.dart';

abstract class ControllableEntryEditorViewModel<C extends Controllable>
    extends ChangeNotifier {
  ControllableEntryEditorViewModel({
    required this.getEntry,
    required this.getController,
  });

  late final bool isNew;
  late final bool isEditing;
  late final bool isReadOnly;

  late final String controllerId;
  late final String? entryId;
  final formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};
  final GetEntity<Entry> getEntry;
  final GetEntity<C> getController;

  AsyncSnapshot<C> controller = AsyncSnapshot.nothing();
  AsyncSnapshot<Entry> entry = AsyncSnapshot.nothing();

  ControllableEntryEditorViewModel<C> readOnly(bool value) {
    isReadOnly = value;
    return this;
  }

  ControllableEntryEditorViewModel<C> withEntry(String? value) {
    entryId = value;
    return this;
  }

  ControllableEntryEditorViewModel<C> withController(String value) {
    controllerId = value;
    return this;
  }

  Future<void> initialize() async {
    isNew = !isReadOnly && entryId == null;
    isEditing = !isReadOnly && entryId != null;

    controller = AsyncSnapshot.waiting();

    notifyListeners();

    try {
      controller = AsyncSnapshot.withData(
        ConnectionState.done,
        await getController.execute(controllerId),
      );
    } catch (error, stackTrace) {
      controller = AsyncSnapshot.withError(
        ConnectionState.done,
        error,
        stackTrace,
      );
    }

    if (entryId != null) {
      entry = AsyncSnapshot.waiting();
      try {
        entry = AsyncSnapshot.withData(
          ConnectionState.done,
          await getEntry.execute(entryId!),
        );
      } catch (error, stackTrace) {
        entry = AsyncSnapshot.withError(
          ConnectionState.done,
          error,
          stackTrace,
        );
      }
    }

    fill(entry.hasData ? Draft<Entry>(entry.requireData) : null);

    notifyListeners();
  }

  Future<Draft<Entry>> create();
  Draft<Entry>? fill(Draft<Entry>? draft);

  Future<Draft<Entry>> save() async {
    return create();
  }
}
