import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class CreateClassifierParams<T extends Classifier<T>> {
  final String name;
  CreateClassifierParams({required this.name});
}

class CreateClassifier<T extends Classifier<T>>
    extends UseCase<CreateClassifierParams<T>, T> {
  final ClassifierRepository<T> repository;
  final T Function({required String name}) factory;

  CreateClassifier({required this.repository, required this.factory});

  factory CreateClassifier.fromContainer(
    DependencyContainer c, {
    required T Function({required String name}) factory,
  }) {
    return CreateClassifier<T>(
      repository: c.get<ClassifierRepository<T>>(),
      factory: factory,
    );
  }

  @override
  Future<T> execute(CreateClassifierParams<T> params) async {
    final classifier = factory(name: params.name);
    await repository.save(classifier);
    return classifier;
  }
}
