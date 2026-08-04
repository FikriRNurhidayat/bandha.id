import 'package:bandha/core/data/repository_impl.dart';
import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/data/data_sources/classifier_local_storage.dart';
import 'package:bandha/modules/classifiers/domain/entities/classifier.dart';
import 'package:bandha/modules/classifiers/domain/ports/classifier_reader.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';

class ClassifierRepositoryImpl<T extends Classifier<T>>
    extends RepositoryImpl<T>
    implements ClassifierRepository<T>, ClassifierReader<T> {
  @override
  final ClassifierLocalStorage<T> localStorage;

  ClassifierRepositoryImpl(this.localStorage);

  factory ClassifierRepositoryImpl.fromContainer(DependencyContainer c) {
    return ClassifierRepositoryImpl(c.get<ClassifierLocalStorage<T>>());
  }
}
