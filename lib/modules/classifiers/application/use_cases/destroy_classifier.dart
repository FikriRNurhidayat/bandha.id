import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class DestroyClassifierParams<T extends Classifier<T>> {
  final String id;

  DestroyClassifierParams(this.id);
}

class DestroyClassifier<T extends Classifier<T>>
    extends UseCase<DestroyClassifierParams<T>, void> {
  final UnitOfWork unitOfWork;
  final ClassifierRepository<T> repository;

  DestroyClassifier({required this.repository, required this.unitOfWork});

  factory DestroyClassifier.fromContainer(DependencyContainer c) {
    return DestroyClassifier<T>(
      repository: c.get<ClassifierRepository<T>>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  @override
  Future<void> execute(DestroyClassifierParams<T> params) async {
    return unitOfWork.execute(() async {
      final classifier = await repository.get(params.id);
      await repository.destroy(classifier);
    });
  }
}
