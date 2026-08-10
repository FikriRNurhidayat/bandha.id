import 'package:bandha/core/di/dependency_container.dart';
import 'package:bandha/core/di/module.dart';
import 'package:bandha/modules/classifiers/application/use_cases/create_classifier.dart';
import 'package:bandha/modules/classifiers/application/use_cases/destroy_classifier.dart';
import 'package:bandha/modules/classifiers/application/use_cases/get_classifier.dart';
import 'package:bandha/modules/classifiers/application/use_cases/query_classifiers.dart';
import 'package:bandha/modules/classifiers/application/use_cases/update_classifier.dart';
import 'package:bandha/modules/classifiers/data/data_sources/category_local_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/category_sqlite_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/label_local_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/label_sqlite_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/party_local_storage.dart';
import 'package:bandha/modules/classifiers/data/data_sources/party_sqlite_storage.dart';
import 'package:bandha/modules/classifiers/data/repositories/category_repository_impl.dart';
import 'package:bandha/modules/classifiers/data/repositories/label_repository_impl.dart';
import 'package:bandha/modules/classifiers/data/repositories/party_repository_impl.dart';
import 'package:bandha/modules/classifiers/domain/entities/category.dart';
import 'package:bandha/modules/classifiers/domain/entities/label.dart';
import 'package:bandha/modules/classifiers/domain/entities/party.dart';
import 'package:bandha/modules/classifiers/domain/ports/category_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/label_reader.dart';
import 'package:bandha/modules/classifiers/domain/ports/party_reader.dart';
import 'package:bandha/modules/classifiers/domain/repositories/category_repository.dart';
import 'package:bandha/modules/classifiers/domain/repositories/classifier_repository.dart';
import 'package:bandha/modules/classifiers/domain/repositories/label_repository.dart';
import 'package:bandha/modules/classifiers/domain/repositories/party_repository.dart';

class ClassifierModule extends Module {
  @override
  Future<void> provide(DependencyContainer c) async {
    c.registerSingleton<CategorySqliteStorage>(
      CategorySqliteStorage.build(c),
    );
    c.registerSingleton<LabelSqliteStorage>(
      LabelSqliteStorage.build(c),
    );
    c.registerSingleton<PartySqliteStorage>(
      PartySqliteStorage.build(c),
    );

    c.registerSingleton<CategoryLocalStorage>(c.get<CategorySqliteStorage>());
    c.registerSingleton<LabelLocalStorage>(c.get<LabelSqliteStorage>());
    c.registerSingleton<PartyLocalStorage>(c.get<PartySqliteStorage>());

    c.registerSingleton<CategoryRepositoryImpl>(
      CategoryRepositoryImpl.build(c),
    );
    c.registerSingleton<LabelRepositoryImpl>(
      LabelRepositoryImpl.build(c),
    );
    c.registerSingleton<PartyRepositoryImpl>(
      PartyRepositoryImpl.build(c),
    );

    c.registerSingleton<CategoryRepository>(c.get<CategoryRepositoryImpl>());
    c.registerSingleton<LabelRepository>(c.get<LabelRepositoryImpl>());
    c.registerSingleton<PartyRepository>(c.get<PartyRepositoryImpl>());
    c.registerSingleton<ClassifierRepository<Category>>(
      c.get<CategoryRepositoryImpl>(),
    );
    c.registerSingleton<ClassifierRepository<Label>>(
      c.get<LabelRepositoryImpl>(),
    );
    c.registerSingleton<ClassifierRepository<Party>>(
      c.get<PartyRepositoryImpl>(),
    );

    c.registerSingleton<CategoryReader>(c.get<CategoryRepositoryImpl>());
    c.registerSingleton<LabelReader>(c.get<LabelRepositoryImpl>());
    c.registerSingleton<PartyReader>(c.get<PartyRepositoryImpl>());
  }

  @override
  Future<void> compose(DependencyContainer c) async {
    c.registerSingleton<CreateClassifier<Category>>(
      CreateClassifier<Category>.build(c, factory: Category.create),
    );
    c.registerSingleton<CreateClassifier<Label>>(
      CreateClassifier<Label>.build(c, factory: Label.create),
    );
    c.registerSingleton<CreateClassifier<Party>>(
      CreateClassifier<Party>.build(c, factory: Party.create),
    );

    c.registerSingleton<UpdateClassifier<Category>>(
      UpdateClassifier<Category>.build(c),
    );
    c.registerSingleton<UpdateClassifier<Label>>(
      UpdateClassifier<Label>.build(c),
    );
    c.registerSingleton<UpdateClassifier<Party>>(
      UpdateClassifier<Party>.build(c),
    );

    c.registerSingleton<DestroyClassifier<Category>>(
      DestroyClassifier<Category>.build(c),
    );
    c.registerSingleton<DestroyClassifier<Label>>(
      DestroyClassifier<Label>.build(c),
    );
    c.registerSingleton<DestroyClassifier<Party>>(
      DestroyClassifier<Party>.build(c),
    );

    c.registerSingleton<GetClassifier<Category>>(
      GetClassifier<Category>.build(c),
    );
    c.registerSingleton<GetClassifier<Label>>(
      GetClassifier<Label>.build(c),
    );
    c.registerSingleton<GetClassifier<Party>>(
      GetClassifier<Party>.build(c),
    );

    c.registerSingleton<QueryClassifiers<Category>>(
      QueryClassifiers<Category>.build(c),
    );
    c.registerSingleton<QueryClassifiers<Label>>(
      QueryClassifiers<Label>.build(c),
    );
    c.registerSingleton<QueryClassifiers<Party>>(
      QueryClassifiers<Party>.build(c),
    );
  }
}
