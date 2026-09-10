import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/dependency_injector.dart';
import 'package:bandha/core/presentation/models/item.dart';
import 'package:bandha/core/presentation/view_models/async_list_view_model.dart';
import 'package:bandha/modules/classifiers/application/use_cases/create_classifier.dart';
import 'package:bandha/modules/classifiers/application/use_cases/update_classifier.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:flutter/material.dart';

class ClassifierSelectViewModel<T extends Classifier<T>>
    extends AsyncListViewModel<T> {
  final CreateClassifier<T> createClassifier;
  final UpdateClassifier<T> updateClassifier;

  ClassifierSelectViewModel({
    required super.queryEntities,
    required super.destroyEntity,
    required this.createClassifier,
    required this.updateClassifier,
  });

  factory ClassifierSelectViewModel.of(BuildContext context) {
    return DependencyInjector.of(context).get<ClassifierSelectViewModel<T>>();
  }

  factory ClassifierSelectViewModel.build(DependencyContainer c) {
    return ClassifierSelectViewModel<T>(
      queryEntities: c.get<QueryEntities<T>>(),
      destroyEntity: c.get<DestroyEntity<T>>(),
      createClassifier: c.get<CreateClassifier<T>>(),
      updateClassifier: c.get<UpdateClassifier<T>>(),
    );
  }

  Future<void> create(String name) async {
    final classifier = await createClassifier.execute(name: name);
    final item = Item<T>(classifier);
    candidatesNotifier.value.add(item);

    notifier.value = AsyncSnapshot.withData(
      ConnectionState.done,
      notifier.value.requireData.followedBy([item]),
    );
  }

  Future<void> update(String id, {required String name}) async {
    final classifier = await updateClassifier.execute(id, name: name);
    final item = Item<T>(classifier);
    await updateItem(item);
  }
}
