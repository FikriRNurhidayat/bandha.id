import 'package:bandha/core/application/use_cases/query_entities.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/domain/repository.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class QueryClassifiers<T extends Classifier<T>> extends QueryEntities<T> {
  final ClassifierRepository<T> classifierRepository;

  QueryClassifiers({required this.classifierRepository})
    : super(classifierRepository);

  @override
  Repository<T> get repository => classifierRepository;

  factory QueryClassifiers.build(DependencyContainer c) {
    return QueryClassifiers(
      classifierRepository: c.get<ClassifierRepository<T>>(),
    );
  }
}
