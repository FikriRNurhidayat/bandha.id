import 'package:bandha/core/application/use_cases/destroy_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/core/domain/unit_of_work.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class DestroyClassifier<T extends Classifier<T>> extends DestroyEntity<T> {
  final UnitOfWork unitOfWork;

  final ClassifierRepository<T> classifierRepository;

  @override
  Repository<T> get repository => classifierRepository;

  DestroyClassifier({
    required this.classifierRepository,
    required this.unitOfWork,
  }) : super(classifierRepository);

  factory DestroyClassifier.build(DependencyContainer c) {
    return DestroyClassifier<T>(
      classifierRepository: c.get<ClassifierRepository<T>>(),
      unitOfWork: c.get<UnitOfWork>(),
    );
  }

  @override
  Future<void> execute(String id) async {
    return unitOfWork.execute(() async {
      final classifier = await repository.get(id);
      await repository.destroy(classifier);
    });
  }
}
