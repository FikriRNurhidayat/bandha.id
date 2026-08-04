import 'package:bandha/core/application/use_cases/get_entity.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class GetClassifier<T extends Classifier<T>> extends GetEntity<T> {
  final ClassifierRepository<T> classifierRepository;

  GetClassifier({required this.classifierRepository})
    : super(classifierRepository);

  @override
  Repository<T> get repository => classifierRepository;

  factory GetClassifier.fromContainer(DependencyContainer c) {
    return GetClassifier(
      classifierRepository: c.get<ClassifierRepository<T>>(),
    );
  }
}
