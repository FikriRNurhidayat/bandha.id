import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class CreateClassifier<T extends Classifier<T>> {
  final ClassifierRepository<T> repository;
  final T Function({required String name}) factory;

  CreateClassifier({required this.repository, required this.factory});

  factory CreateClassifier.build(
    DependencyContainer c, {
    required T Function({required String name}) factory,
  }) {
    return CreateClassifier<T>(
      repository: c.get<ClassifierRepository<T>>(),
      factory: factory,
    );
  }

  Future<T> execute({required String name}) async {
    final classifier = factory(name: name);
    await repository.save(classifier);
    return classifier;
  }
}
