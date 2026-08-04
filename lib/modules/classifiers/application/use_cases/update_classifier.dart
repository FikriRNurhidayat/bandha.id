import 'package:bandha/core/application/use_case.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class UpdateClassifierParams<T extends Classifier<T>> {
  final String id;
  final String name;

  UpdateClassifierParams(this.id, {required this.name});
}

class UpdateClassifier<T extends Classifier<T>>
    extends UseCase<UpdateClassifierParams<T>, T> {
  final UnitOfWork unitOfWork;
  final ClassifierRepository<T> repository;

  UpdateClassifier({required this.repository, required this.unitOfWork});

  factory UpdateClassifier.fromContainer(DependencyContainer c) {
    return UpdateClassifier<T>(
      repository: c.get<ClassifierRepository<T>>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  @override
  Future<T> execute(UpdateClassifierParams<T> params) async {
    return unitOfWork.execute<T>(() async {
      final classifier = await repository.get(params.id);
      return await repository.save(classifier.copyWith(name: params.name));
    });
  }
}
