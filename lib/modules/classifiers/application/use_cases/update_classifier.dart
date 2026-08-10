import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class UpdateClassifier<T extends Classifier<T>> {
  final UnitOfWork unitOfWork;
  final ClassifierRepository<T> repository;

  UpdateClassifier({required this.repository, required this.unitOfWork});

  factory UpdateClassifier.build(DependencyContainer c) {
    return UpdateClassifier<T>(
      repository: c.get<ClassifierRepository<T>>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  Future<T> execute(String id, {required String name}) async {
    return unitOfWork.execute<T>(() async {
      final classifier = await repository.get(id);
      return await repository.save(classifier.copyWith(name: name));
    });
  }
}
