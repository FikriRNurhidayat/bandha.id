import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/modules/classifiers/data/data_sources/category_local_storage.dart';
import 'package:bandha/modules/classifiers/data/repositories/classifier_repository_impl.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl extends ClassifierRepositoryImpl<Category>
    implements CategoryRepository, CategoryReader {
  CategoryRepositoryImpl(super.localStorage);

  factory CategoryRepositoryImpl.build(DependencyContainer c) {
    return CategoryRepositoryImpl(c.get<CategoryLocalStorage>());
  }
}
