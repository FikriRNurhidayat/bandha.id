import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class DestroyClassifier<T extends Classifier<T>> {
  final UnitOfWork unitOfWork;
  final ClassifierRepository<T> repository;

  DestroyClassifier({required this.repository, required this.unitOfWork});

  factory DestroyClassifier.build(DependencyContainer c) {
    return DestroyClassifier<T>(
      repository: c.get<ClassifierRepository<T>>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  Future<void> execute(String id) async {
    return unitOfWork.execute(() async {
      final classifier = await repository.get(id);
      await repository.destroy(classifier);
    });
  }
}
