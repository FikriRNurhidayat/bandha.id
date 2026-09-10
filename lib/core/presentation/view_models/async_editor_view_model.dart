import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/domain/entity.dart';
import 'package:bandha/core/presentation/models/draft.dart';
import 'package:bandha/core/presentation/view_models/async_view_model.dart';
import 'package:flutter/material.dart';

class Field<T> {
  final String name;
  final String label;
  final T? initialValue;

  Field({required this.name, required this.label, this.initialValue});
}

abstract class AsyncEditorViewModel<E extends Entity>
    extends AsyncViewModel<Draft<E>> {
  abstract final GetEntity<E> getEntity;

  late final bool isNew;
  late final bool isEditing;
  late final bool isReadOnly;
  late final String? id;

  final formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

  Future<Draft<E>> onCreate();
  Future<Draft<E>> onUpdate();
  Future<Draft<E>> fill(Draft<E> draft);

  Future<void> initialize({String? id, bool readOnly = false}) async {
    this.id = id;

    isNew = id == null;
    isReadOnly = readOnly;
    isEditing = !isReadOnly;

    if (id != null) {
      return execute((_) async {
        final entity = await getEntity.execute(id);
        final draft = Draft<E>(entity);
        return fill(draft);
      });
    }
  }

  Future<void> save() => execute((draft) async {
    if (isNew) {
      return onCreate();
    }

    return onUpdate();
  });
}
